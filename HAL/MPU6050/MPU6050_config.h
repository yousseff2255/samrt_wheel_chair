#ifndef MPU6050_CONFIG_H
#define MPU6050_CONFIG_H

/* I2C Address (AD0 pin LOW = 0x68, HIGH = 0x69) */
#define MPU6050_ADDRESS         0x68

/* Tilt thresholds in degrees */
#define MPU6050_TILT_WARNING    20.0f
#define MPU6050_TILT_CUTOFF     45.0f

#endif