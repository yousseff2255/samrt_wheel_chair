#ifndef MPU6050_CONFIG_H
#define MPU6050_CONFIG_H

/* I2C Address (AD0 pin grounded = 0x68) */
#define MPU6050_ADDRESS         0x68

/* tan(20°)*100 = 36 — warning level  */
#define MPU6050_TAN_WARNING_X100    36

/* tan(45°)*100 = 100 — motor cutoff  */
#define MPU6050_TAN_CUTOFF_X100     100

#endif