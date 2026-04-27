#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../../MCAL/I2C/I2C_interface.h"

#include "MAX30100_interface.h"
#include "MAX30100_private.h"
#include "MAX30100_config.h"

/* Circular buffer */
static u16 ir_buffer[SAMPLE_BUFFER_SIZE];
static u8  buffer_index  = 0;
static u8  buffer_filled = 0;

/* Peak detection */
static u8  last_peak_index     = 0;
static u8  peaks_detected      = 0;
static u16 peak_intervals[5];
static u8  peak_interval_index = 0;

/* Last readings stored for alert functions */
static u8 last_hr   = 0;
static u8 last_spo2 = 0;

/* -- I2C Helpers -- */
static void MAX30100_WriteReg(u8 reg, u8 value) {
    I2C_Start();
    I2C_Write((MAX30100_I2C_ADDRESS << 1) | 0);
    I2C_Write(reg);
    I2C_Write(value);
    I2C_Stop();
}

static u8 MAX30100_ReadReg(u8 reg) {
    u8 _data = 0;
    I2C_Start();
    I2C_Write((MAX30100_I2C_ADDRESS << 1) | 0);
    I2C_Write(reg);
    I2C_Restart();
    I2C_Write((MAX30100_I2C_ADDRESS << 1) | 1);
    _data = I2C_Read(I2C_NACK);
    I2C_Stop();
    return _data;
}

/* -- Public Functions -- */
void MAX30100_Reset(void) {
    MAX30100_WriteReg(MAX30100_REG_MODE_CONFIG, 0x40);
    Delay_ms(100);
}

u8 MAX30100_GetPartID(void) {
    return MAX30100_ReadReg(MAX30100_REG_PART_ID);
}

void MAX30100_ClearFIFO(void) {
    MAX30100_WriteReg(MAX30100_REG_FIFO_WR_PTR, 0x00);
    MAX30100_WriteReg(MAX30100_REG_FIFO_RD_PTR, 0x00);
    MAX30100_WriteReg(MAX30100_REG_OVRFLOW_CTR, 0x00);
}

void MAX30100_Init(void) {
    u8 i;
    MAX30100_ClearFIFO();
    MAX30100_WriteReg(MAX30100_REG_SPO2_CONFIG,
                      MAX30100_SPO2_HI_RES_EN |
                      MAX30100_SPO2_SR_100HZ   |
                      MAX30100_SPO2_LED_PW_1600US);
    MAX30100_WriteReg(MAX30100_REG_LED_CONFIG,  MAX30100_LED_CURRENT);
    MAX30100_WriteReg(MAX30100_REG_MODE_CONFIG, MAX30100_MODE_SPO2);

    for (i = 0; i < SAMPLE_BUFFER_SIZE; i++) {
        ir_buffer[i] = 0;
    }
    buffer_index       = 0;
    buffer_filled      = 0;
    peaks_detected     = 0;
    peak_interval_index = 0;
    last_hr            = 0;
    last_spo2          = 0;

    Delay_ms(100);
}

void MAX30100_ReadRaw(u16 *ir, u16 *red) {
    u8 ir_h, ir_l, red_h, red_l;
    I2C_Start();
    I2C_Write((MAX30100_I2C_ADDRESS << 1) | 0);
    I2C_Write(MAX30100_REG_FIFO_DATA);
    I2C_Restart();
    I2C_Write((MAX30100_I2C_ADDRESS << 1) | 1);
    ir_h  = I2C_Read(I2C_ACK);
    ir_l  = I2C_Read(I2C_ACK);
    red_h = I2C_Read(I2C_ACK);
    red_l = I2C_Read(I2C_NACK);
    I2C_Stop();
    *ir  = ((u16)ir_h << 8) | ir_l;
    *red = ((u16)red_h << 8) | red_l;
}

/* -- SpO2 Calculation -- */
u8 MAX30100_GetSpO2(u16 ir, u16 red) {
    u8  spo2 = 0;
    f32 ratio;

    /* Avoid division by zero */
    if (ir == 0) return 0;

    /* R = (AC_red / DC_red) / (AC_ir / DC_ir)
     * Simplified approximation using raw values */
    ratio = (f32)red / (f32)ir;

    /* Empirical formula: SpO2 = 110 - 25 * R */
    spo2 = (u8)(110.0f - (25.0f * ratio));

    /* Clamp to valid range */
    if (spo2 > 100) spo2 = 100;
    if (spo2 < 70)  spo2 = 70;

    last_spo2 = spo2;
    return spo2;
}

/* -- Heart Rate Calculation -- */
static u8 is_peak(u8 index) {
    u8  prev_index, next_index;
    u16 current, prev, next;

    if (index == 0 || index >= (SAMPLE_BUFFER_SIZE - 1)) return 0;

    prev_index = index - 1;
    next_index = index + 1;
    current    = ir_buffer[index];
    prev       = ir_buffer[prev_index];
    next       = ir_buffer[next_index];

    if ((current > prev) && (current > next) && (current > PEAK_THRESHOLD)) {
        return 1;
    }
    return 0;
}

u8 MAX30100_GetHeartRate(void) {
    /* All variables declared at top — MikroC C89 rule */
    u16 ir_value, red_value;
    u8  check_index;
    u8  distance;
    u8  i;
    u16 avg_interval  = 0;
    u32 sum_intervals = 0;
    u8  valid_intervals = 0;
    u8  heart_rate    = 0;

    MAX30100_ReadRaw(&ir_value, &red_value);

    /* Store in circular buffer */
    ir_buffer[buffer_index] = ir_value;
    buffer_index++;
    if (buffer_index >= SAMPLE_BUFFER_SIZE) {
        buffer_index  = 0;
        buffer_filled = 1;
    }

    if (!buffer_filled) return 0;

    check_index = (buffer_index > 0) ? (buffer_index - 1) : (SAMPLE_BUFFER_SIZE - 1);

    if (is_peak(check_index)) {
        /* Calculate distance from last peak — declared at top */
        if (buffer_index > last_peak_index) {
            distance = buffer_index - last_peak_index;
        } else {
            distance = (SAMPLE_BUFFER_SIZE - last_peak_index) + buffer_index;
        }

        if (distance >= MIN_PEAK_DISTANCE && peaks_detected > 0) {
            peak_intervals[peak_interval_index] = distance;
            peak_interval_index++;
            if (peak_interval_index >= 5) peak_interval_index = 0;
            if (peaks_detected < 5)       peaks_detected++;
        }

        last_peak_index = check_index;
        if (peaks_detected == 0) peaks_detected = 1;
    }

    if (peaks_detected >= 3) {
        for (i = 0; i < peaks_detected && i < 5; i++) {
            if (peak_intervals[i] > 0) {
                sum_intervals += peak_intervals[i];
                valid_intervals++;
            }
        }
        if (valid_intervals > 0) {
            avg_interval = (u16)(sum_intervals / valid_intervals);
            /* 100Hz sample rate: BPM = 6000 / interval */
            heart_rate = (u8)(6000UL / avg_interval);
            if (heart_rate < 40 || heart_rate > 200) heart_rate = 0;
        }
    }

    last_hr = heart_rate;
    return heart_rate;
}

/* -- Alert Functions for APP layer -- */
u8 MAX30100_IsHRAlert(void) {
    return (last_hr < MAX30100_HR_LOW || last_hr > MAX30100_HR_HIGH) ? 1 : 0;
}

u8 MAX30100_IsSpO2Alert(void) {
    return (last_spo2 < MAX30100_SPO2_LOW) ? 1 : 0;
}