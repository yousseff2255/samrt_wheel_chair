#ifndef MPU6050_CONFIG_H
#define MPU6050_CONFIG_H

/* I2C Address (AD0 pin LOW = 0x68) */
#define MPU6050_ADDRESS         0x68

/* Tilt threshold in degrees — beyond this is a fall */
#define MPU6050_TILT_WARNING    20  /* First level — push notification */
#define MPU6050_TILT_CUTOFF     45  /* Second level — motor cutoff */

#endif