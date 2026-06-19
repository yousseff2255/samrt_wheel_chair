#define _XTAL_FREQ 10000000UL  /* 10 MHz Crystal */

/* =============================================================
 * MPU6050.c — Integer-only driver (no float / no libm)
 * PIC16F877A @ 10 MHz
 * =============================================================
 * Tilt is stored as tan(angle)*100 using integer division.
 * This avoids atan2f/sqrtf which cost ~700 words of flash.
 *
 * Threshold equivalents:
 *   tan(20°)*100 = 36  → MPU6050_TAN_WARNING_X100
 *   tan(45°)*100 = 100 → MPU6050_TAN_CUTOFF_X100
 * ============================================================= */

#include <xc.h>
#include "../../SERVICES/STD_TYPES.h"
#include "../../MCAL/I2C/I2C_interface.h"
#include "MPU6050_interface.h"
#include "MPU6050_private.h"
#include "MPU6050_config.h"

/* ── Calibration biases (raw LSB units) ──────────────────────────────────── */
static s16 s_axBias = 0;
static s16 s_ayBias = 0;
static s16 s_azBias = 0;

/* ── EMA-filtered tilt output (tan*100 units) ────────────────────────────── */
static MPU6050_Tilt s_tilt = {0, 0};

/* ── Private: write one register ─────────────────────────────────────────── */
static void MPU6050_WriteReg(u8 reg, u8 value) {
    I2C_Start();
    I2C_Write((MPU6050_ADDRESS << 1) | 0);
    I2C_Write(reg);
    I2C_Write(value);
    I2C_Stop();
}

/* ── Private: burst-read raw accel axes ──────────────────────────────────── */
static void MPU6050_ReadRaw(s16 *ax, s16 *ay, s16 *az) {
    u8 buf[6];

    I2C_Start();
    I2C_Write((MPU6050_ADDRESS << 1) | 0);
    I2C_Write(MPU6050_REG_ACCEL_XOUT_H);
    I2C_Repeated_Start();
    I2C_Write((MPU6050_ADDRESS << 1) | 1);
    buf[0] = I2C_Read(I2C_ACK);
    buf[1] = I2C_Read(I2C_ACK);
    buf[2] = I2C_Read(I2C_ACK);
    buf[3] = I2C_Read(I2C_ACK);
    buf[4] = I2C_Read(I2C_ACK);
    buf[5] = I2C_Read(I2C_NACK);
    I2C_Stop();

    *ax = (s16)((buf[0] << 8) | buf[1]);
    *ay = (s16)((buf[2] << 8) | buf[3]);
    *az = (s16)((buf[4] << 8) | buf[5]);
}

/* ── MPU6050_Init ─────────────────────────────────────────────────────────── */
void MPU6050_Init(void) {
    __delay_ms(100);

    /* Use gyro PLL as clock source — more stable than internal RC */
    MPU6050_WriteReg(MPU6050_REG_PWR_MGMT_1,  0x01);

    /* DLPF_CFG = 3 → 44 Hz accel bandwidth, cuts vibration noise */
    MPU6050_WriteReg(MPU6050_REG_CONFIG,       0x03);

    /* Sample rate = 1 kHz / (1 + 9) = 100 Hz */
    MPU6050_WriteReg(MPU6050_REG_SMPLRT_DIV,   0x09);

    /* Accel full scale = ±2g (default, set explicitly) */
    MPU6050_WriteReg(MPU6050_REG_ACCEL_CONFIG, 0x00);
}

/* ── MPU6050_Calibrate ────────────────────────────────────────────────────── */
/* Keep sensor flat and still while this runs (~500 ms).
 * Averages 50 samples to find the per-axis bias.
 * Z bias accounts for the expected 1g gravity reading.          */
void MPU6050_Calibrate(void) {
    s32 sumX = 0, sumY = 0, sumZ = 0;
    s16 ax, ay, az;
    u8  i;

    for (i = 0u; i < 50u; i++) {
        MPU6050_ReadRaw(&ax, &ay, &az);
        sumX += (s32)ax;
        sumY += (s32)ay;
        sumZ += (s32)az;
        __delay_ms(10);
    }

    s_axBias = (s16)(sumX / 50L);
    s_ayBias = (s16)(sumY / 50L);
    /* Z axis reads ~16384 LSB when flat (1g at ±2g range).
     * Bias is how far it deviates from that expected value.      */
    s_azBias = (s16)((sumZ / 50L) - 16384L);
}

/* ── MPU6050_Update ───────────────────────────────────────────────────────── */
/* Call regularly (e.g. every 10 ms).
 * Reads sensor, removes bias, computes integer tilt ratio,
 * then applies a lightweight integer EMA filter.
 *
 * Tilt ratio = (axis / az) * 100  ≈  tan(angle) * 100
 * No trigonometric functions needed.                            */
void MPU6050_Update(void) {
    s16 ax, ay, az;
    s16 rawX, rawY;

    MPU6050_ReadRaw(&ax, &ay, &az);

    /* Remove calibration bias */
    ax -= s_axBias;
    ay -= s_ayBias;
    az -= s_azBias;

    /* Guard against near-zero az (sensor near 90° or free-fall).
     * Clamp to ±1000 LSB minimum so division stays meaningful.  */
    if (az >= 0 && az < 1000)  az =  1000;
    if (az <  0 && az > -1000) az = -1000;

    /* Tilt ratio scaled by 100:
     *   rawX = tan(tilt_around_X) * 100  (driven by ay vs az)
     *   rawY = tan(tilt_around_Y) * 100  (driven by ax vs az)   */
    rawX = (s16)((s32)ay * 100L / (s32)az);
    rawY = (s16)((s32)ax * 100L / (s32)az);

    /* Integer EMA: weight = 2/8 = 0.25 (same as float alpha=0.25)
     * new_ema = (2*new + 6*old) / 8                              */
    s_tilt.x = (s16)((2 * (s32)rawX + 6 * (s32)s_tilt.x) / 8L);
    s_tilt.y = (s16)((2 * (s32)rawY + 6 * (s32)s_tilt.y) / 8L);
}

/* ── MPU6050_GetTilt ──────────────────────────────────────────────────────── */
/* Returns the cached tilt — no I2C, safe to call anytime after Update(). */
void MPU6050_GetTilt(MPU6050_Tilt *tilt) {
    if (tilt != NULL) {
        *tilt = s_tilt;
    }
}

/* ── MPU6050_IsWarning ────────────────────────────────────────────────────── */
/* Returns 1 if tilt exceeds WARNING threshold (default: ~20°).
 * Compares tan(angle)*100 against MPU6050_TAN_WARNING_X100 = 36. */
u8 MPU6050_IsWarning(void) {
    s16 absX = (s_tilt.x < 0) ? -s_tilt.x : s_tilt.x;
    s16 absY = (s_tilt.y < 0) ? -s_tilt.y : s_tilt.y;
    return (absX > MPU6050_TAN_WARNING_X100 ||
            absY > MPU6050_TAN_WARNING_X100) ? 1u : 0u;
}

/* ── MPU6050_IsFalling ────────────────────────────────────────────────────── */
/* Returns 1 if tilt exceeds CUTOFF threshold (default: ~45°).
 * Compares tan(angle)*100 against MPU6050_TAN_CUTOFF_X100 = 100. */
u8 MPU6050_IsFalling(void) {
    s16 absX = (s_tilt.x < 0) ? -s_tilt.x : s_tilt.x;
    s16 absY = (s_tilt.y < 0) ? -s_tilt.y : s_tilt.y;
    return (absX > MPU6050_TAN_CUTOFF_X100 ||
            absY > MPU6050_TAN_CUTOFF_X100) ? 1u : 0u;
}