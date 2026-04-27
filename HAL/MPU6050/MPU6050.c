#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../../MCAL/I2C/I2C_interface.h"

#include "MPU6050_interface.h"
#include "MPU6050_private.h"
#include "MPU6050_config.h"

#include <math.h>   /* for atan2 and sqrt */

/* ── Helper: write to an MPU6050 internal register ── */
static void MPU6050_WriteReg(u8 reg, u8 value) {
    I2C_Start();
    I2C_Write((MPU6050_ADDRESS << 1) | 0);  /* Address + Write bit */
    I2C_Write(reg);
    I2C_Write(value);
    I2C_Stop();
}

/* ── Helper: read a single byte from an MPU6050 register ── */
static u8 MPU6050_ReadReg(u8 reg) {
    u8 data = 0;

    /* First: tell MPU which register we want */
    I2C_Start();
    I2C_Write((MPU6050_ADDRESS << 1) | 0);  /* Address + Write */
    I2C_Write(reg);

    /* Then: read from it */
    I2C_Restart();
    I2C_Write((MPU6050_ADDRESS << 1) | 1);  /* Address + Read */
    data = I2C_Read(I2C_NACK);              /* NACK on last byte */
    I2C_Stop();

    return data;
}

/* ── Helper: read two bytes and combine into signed 16-bit ── */
static s16 MPU6050_ReadAxis(u8 highReg) {
    u8 high = MPU6050_ReadReg(highReg);
    u8 low  = MPU6050_ReadReg(highReg + 1);
    return (s16)((high << 8) | low);
}

void MPU6050_Init(void) {
    /* Wake up MPU6050 — PWR_MGMT_1 = 0 clears sleep bit */
    MPU6050_WriteReg(MPU6050_REG_PWR_MGMT_1, 0x00);
}

void MPU6050_GetTilt(MPU6050_Tilt* tilt) {
    s16 ax_raw, ay_raw, az_raw;
    f32 ax, ay, az;

    /* 1. Read raw accelerometer values */
    ax_raw = MPU6050_ReadAxis(MPU6050_REG_ACCEL_XOUT_H);
    ay_raw = MPU6050_ReadAxis(MPU6050_REG_ACCEL_YOUT_H);
    az_raw = MPU6050_ReadAxis(MPU6050_REG_ACCEL_ZOUT_H);

    /* 2. Convert to g units */
    ax = (f32)ax_raw / MPU6050_ACCEL_SENSITIVITY;
    ay = (f32)ay_raw / MPU6050_ACCEL_SENSITIVITY;
    az = (f32)az_raw / MPU6050_ACCEL_SENSITIVITY;

    /* 3. Calculate tilt angles in degrees */
    /* X tilt: rotation around X axis */
    tilt->x = atan2(ay, sqrt(ax * ax + az * az)) * (180.0f / 3.14159f);
    /* Y tilt: rotation around Y axis */
    tilt->y = atan2(ax, sqrt(ay * ay + az * az)) * (180.0f / 3.14159f);
}

u8 MPU6050_IsWarning(void) {
    MPU6050_Tilt tilt;
    MPU6050_GetTilt(&tilt);

    f32 absX = tilt.x < 0 ? -tilt.x : tilt.x;
    f32 absY = tilt.y < 0 ? -tilt.y : tilt.y;

    return (absX > MPU6050_TILT_WARNING || absY > MPU6050_TILT_WARNING) ? 1 : 0;
}

u8 MPU6050_IsFalling(void) {
    MPU6050_Tilt tilt;
    MPU6050_GetTilt(&tilt);

    f32 absX = tilt.x < 0 ? -tilt.x : tilt.x;
    f32 absY = tilt.y < 0 ? -tilt.y : tilt.y;

    return (absX > MPU6050_TILT_CUTOFF || absY > MPU6050_TILT_CUTOFF) ? 1 : 0;
}