#ifndef MPU6050_PRIVATE_H
#define MPU6050_PRIVATE_H

#include "../../SERVICES/STD_TYPES.h"
#include "../../MCAL/REGISTERS/PIC16F877A_reg.h"

/* Registers */
#define MPU6050_REG_SMPLRT_DIV      0x19
#define MPU6050_REG_CONFIG          0x1A  /* DLPF lives here */
#define MPU6050_REG_ACCEL_CONFIG    0x1C
#define MPU6050_REG_ACCEL_XOUT_H    0x3B
#define MPU6050_REG_PWR_MGMT_1      0x6B


/* Default ±2g range = 16384 LSB/g */
#define MPU6050_ACCEL_SENSITIVITY   16384.0f

/* EMA smoothing factor (0.0–1.0): lower = smoother but slower response
 * 0.2 is a good starting point for a 50–100 Hz update rate             */
#define MPU6050_EMA_ALPHA           0.2f

/* How many samples to average during calibration */
#define MPU6050_CALIB_SAMPLES       200u

#endif