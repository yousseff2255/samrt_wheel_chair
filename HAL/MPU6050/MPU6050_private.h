#ifndef MPU6050_PRIVATE_H
#define MPU6050_PRIVATE_H

/* Registers */
#define PWR_MGMT_1              0x6B
#define ACCEL_XOUT_H            0x3B

/* Constants */
#define ACCEL_SENSITIVITY       16384.0f
#define RAD_TO_DEG              57.29577f  /* 180 / 3.14159 */

/* Static Helpers */
static void MPU6050_WriteReg(u8 reg, u8 value);
static void MPU6050_ReadBurst(u8 startReg, u8* buffer, u8 size);

#endif