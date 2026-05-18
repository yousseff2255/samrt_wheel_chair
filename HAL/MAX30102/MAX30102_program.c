#define _XTAL_FREQ 10000000UL  /* 10 MHz Crystal */

/* =============================================================
 * MAX30102_program.c — Integer-only, no float
 * PIC16F877A @ 10 MHz
 * =============================================================
 * DC removal uses fixed-point scaled integers (alpha = 19/20)
 * instead of float, saving ~300 words of flash.
 * ============================================================= */

#include <xc.h>
#include <stdint.h>
#include "../../SERVICES/STD_TYPES.h"
#include "../../MCAL/I2C/I2C_interface.h"
#include "MAX30102_interface.h"
#include "MAX30102_private.h"
#include "MAX30102_config.h"

/* ── State ─────────────────────────────────────────────────────────────────── */
static MAX30102_Result_t s_result;

static DC_Filter_t irDC  = {0};
static DC_Filter_t redDC = {0};
static MA_Filter_t irMA  = {{0}, 0};

static uint32_t s_lastBeatTime = 0;
static int16_t  s_lastIrAC     = 0;

static uint16_t s_bpmBuffer[BPM_BUFFER_SIZE] = {0};
static uint8_t  s_bpmIdx   = 0;
static uint8_t  s_bpmCount = 0;

extern volatile uint32_t g_systemTick_ms;

/* ── DC Removal — fixed-point, NO float ────────────────────────────────────── */
/*
 * Equivalent to:  prevDC = 0.95*prevDC + 0.05*raw
 *                 AC     = raw - prevDC
 *
 * Implemented as: prevDC_scaled = (19 * prevDC_scaled + raw * 20) / 20
 *                 where prevDC_scaled = prevDC * 1024  (10-bit fraction)
 *
 * Keeps enough precision for the 18-bit MAX30102 ADC values without float.
 */
/* ?? DC Removal ?? fixed-point, NO float ?? Corrected for 32-bit Overflow ?? */
static int16_t DC_Removal(uint32_t raw, DC_Filter_t *f) {
    /* * Scale by 256 instead of 1024 to prevent 32-bit signed overflow.
     * Formula: prevDC_scaled = (19 * prevDC_scaled + raw * 256) / 20
     */
    f->prevDC_scaled = (19L * f->prevDC_scaled + ((int32_t)raw * 256L)) / 20L;

    /* AC = raw - (prevDC_scaled / 256) */
    int32_t ac = (int32_t)raw - (f->prevDC_scaled / 256L);

    /* Clamp to int16 range ?? MAX30102 AC swing is well within �32767 */
    if (ac >  32767L) ac =  32767L;
    if (ac < -32768L) ac = -32768L;
    
    return (int16_t)ac;
}

/* ── Moving Average — unchanged, already integer ───────────────────────────── */
static int16_t MA_Filter(int16_t in, MA_Filter_t *f) {
    f->buf[f->idx] = in;
    f->idx = (uint8_t)((f->idx + 1u) % MA_WINDOW);
    int32_t sum = 0;
    uint8_t i;
    for (i = 0u; i < MA_WINDOW; i++) sum += f->buf[i];
    return (int16_t)(sum / (int32_t)MA_WINDOW);
}

/* ── Rolling BPM average ────────────────────────────────────────────────────── */
static void BPM_Push(uint16_t bpm) {
    uint32_t sum = 0;
    uint8_t  i;

    s_bpmBuffer[s_bpmIdx] = bpm;
    s_bpmIdx = (uint8_t)((s_bpmIdx + 1u) % BPM_BUFFER_SIZE);
    if (s_bpmCount < BPM_BUFFER_SIZE) s_bpmCount++;

    for (i = 0u; i < s_bpmCount; i++) sum += s_bpmBuffer[i];
    s_result.bpm = (uint8_t)(sum / s_bpmCount);
}

/* ── Register access ────────────────────────────────────────────────────────── */
static void MAX30102_WriteReg(uint8_t reg, uint8_t val) {
    MAX30102_I2C_START();
    MAX30102_I2C_SEND((MAX30102_I2C_ADDRESS << 1) | 0u);
    MAX30102_I2C_SEND(reg);
    MAX30102_I2C_SEND(val);
    MAX30102_I2C_STOP();
}

static uint8_t MAX30102_ReadReg(uint8_t reg) {
    uint8_t val;
    MAX30102_I2C_START();
    MAX30102_I2C_SEND((MAX30102_I2C_ADDRESS << 1) | 0u);
    MAX30102_I2C_SEND(reg);
    MAX30102_I2C_REPEATED_START();
    MAX30102_I2C_SEND((MAX30102_I2C_ADDRESS << 1) | 1u);
    val = MAX30102_I2C_READ(0);
    MAX30102_I2C_STOP();
    return val;
}

/* ── Init ───────────────────────────────────────────────────────────────────── */
MAX30102_Status_t MAX30102_Init(void) {
    uint8_t id = MAX30102_ReadReg(0xFF); // Read Part ID register
    if (id != MAX30102_EXPECTED_PART_ID ) return MAX30102_ERR; // Stop if sensor not found

    MAX30102_WriteReg(MAX30102_REG_MODE_CONFIG, 0x40u); /* reset */
    __delay_ms(100);
    MAX30102_WriteReg(MAX30102_REG_FIFO_CONFIG, 0x1F);  /* Enable Rollover & No Averaging */
    MAX30102_WriteReg(MAX30102_REG_MODE_CONFIG, 0x03u); /* SpO2 mode */
    MAX30102_WriteReg(MAX30102_REG_SPO2_CONFIG, 0x27u); /* 200SPS, 16-bit */
    MAX30102_WriteReg(MAX30102_REG_LED1_PA, MAX30102_RED_PA);
    MAX30102_WriteReg(MAX30102_REG_LED2_PA, MAX30102_IR_PA);
    return MAX30102_OK;
}

/* ── Update ─────────────────────────────────────────────────────────────────── */
/* ?? Update ???????????????????????????????????????????????????????? */
/* ?? Update ???????????????????????????????????????????????????????? */
void MAX30102_Update(void) {
    uint8_t  buf[6];
    uint32_t red, ir;
    int16_t  rawIrAC, rawRedAC;
    uint8_t  i;

    /* 1. Check FIFO pointers */
    uint8_t wrPtr = MAX30102_ReadReg(MAX30102_REG_FIFO_WR_PTR);
    uint8_t rdPtr = MAX30102_ReadReg(MAX30102_REG_FIFO_RD_PTR);
    
    /* 2. Calculate how many samples are waiting in the FIFO */
    int8_t numSamples = wrPtr - rdPtr;
    if (numSamples < 0) {
        numSamples += 32; /* Handle FIFO rollover math */
    }
    
    if (numSamples == 0) return; /* FIFO is actually empty */

    /* 3. DRAIN THE FIFO: Read all pending samples, not just one! */
    while (numSamples > 0) {
        /* Burst-read one RED + IR sample (6 bytes) */
        MAX30102_I2C_START();
        MAX30102_I2C_SEND((MAX30102_I2C_ADDRESS << 1) | 0u);
        MAX30102_I2C_SEND(MAX30102_REG_FIFO_DATA);
        MAX30102_I2C_REPEATED_START();
        MAX30102_I2C_SEND((MAX30102_I2C_ADDRESS << 1) | 1u);
        for (i = 0u; i < 5u; i++) buf[i] = MAX30102_I2C_READ(1);
        buf[5] = MAX30102_I2C_READ(0);
        MAX30102_I2C_STOP();

        red = ((uint32_t)buf[0] << 16 | (uint32_t)buf[1] << 8 | buf[2]) & 0x3FFFFu;
        ir  = ((uint32_t)buf[3] << 16 | (uint32_t)buf[4] << 8 | buf[5]) & 0x3FFFFu;

        if (ir < MAX30102_FINGER_THRESHOLD) {
            /* Finger removed ? reset all state */
            s_result.fingerDetected = 0;
            s_result.bpm            = 0;
            s_result.spo2           = 0;
            irDC.prevDC_scaled      = 0;
            redDC.prevDC_scaled     = 0;
            s_lastBeatTime          = 0;
            s_lastIrAC              = 0;
            s_bpmIdx                = 0;
            s_bpmCount              = 0;
            for (i = 0u; i < BPM_BUFFER_SIZE; i++) s_bpmBuffer[i] = 0u;
            for (i = 0u; i < MA_WINDOW; i++)       irMA.buf[i]   = 0;
            
            /* CRITICAL: Flush the FIFO to prevent garbage buildup when idle */
            MAX30102_WriteReg(MAX30102_REG_FIFO_WR_PTR, 0);
            MAX30102_WriteReg(MAX30102_REG_FIFO_RD_PTR, 0);
            return;
        }

        /* Instant Filter Seeding */
        if (s_result.fingerDetected == 0) {
            irDC.prevDC_scaled  = (int32_t)ir * 256L;
            redDC.prevDC_scaled = (int32_t)red * 256L;
        }
        s_result.fingerDetected = 1;

        /* DC removal and Moving Average */
        rawIrAC  = DC_Removal(ir,  &irDC);
        rawRedAC = DC_Removal(red, &redDC);

        s_result.irAC  = MA_Filter(rawIrAC, &irMA);
        s_result.redAC = rawRedAC;

        /* Beat detection */
        if (s_result.irAC > BEAT_THRESHOLD && s_lastIrAC <= BEAT_THRESHOLD) {
            uint32_t now   = g_systemTick_ms;
            uint32_t delta = now - s_lastBeatTime;

            if (delta > BEAT_MIN_DELTA_MS && delta < BEAT_MAX_DELTA_MS) {
                BPM_Push((uint16_t)(60000UL / delta));
            }
            s_lastBeatTime = now;
        }
        s_lastIrAC = s_result.irAC;
        
        numSamples--; /* Decrement sample counter */
    }
    
    s_result.spo2 = 98u; /* placeholder */
}
/* ── GetResult ──────────────────────────────────────────────────────────────── */
void MAX30102_GetResult(MAX30102_Result_t *res) {
    if (res != NULL) *res = s_result;
}