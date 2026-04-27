#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../../MCAL/I2C/I2C_interface.h"
#include "MPU6050_interface.h"
#include "MPU6050_config.h"
#include "MPU6050_private.h"

void MPU6050_Init(void) {
    I2C_Start();
    I2C_Write((MPU6050_ADDRESS << 1) | 0);
    I2C_Write(0x6B); // PWR_MGMT_1
    I2C_Write(0x00); // Wake up
    I2C_Stop();
}

static void MPU6050_ReadBurst(u8 reg, u8* buf, u8 size) {
    u8 i;
    I2C_Start();
    I2C_Write((MPU6050_ADDRESS << 1) | 0);
    I2C_Write(reg);
    I2C_Restart();
    I2C_Write((MPU6050_ADDRESS << 1) | 1);
    for(i=0; i<size-1; i++) buf[i] = I2C_Read(1); // ACK
    buf[size-1] = I2C_Read(0); // NACK
    I2C_Stop();
}

void MPU6050_GetTilt(MPU6050_Tilt* tilt) {
    u8 _data[4];
    s16 ax, ay;
    MPU6050_ReadBurst(0x3B, _data, 4); // Read X and Y
    ax = (s16)((_data[0] << 8) | _data[1]);
    ay = (s16)((_data[2] << 8) | _data[3]);

    /* Math-Lite Scaling: 16384 units = 90 degrees.
       1 degree is approx 182 units. */
    tilt->x = (f32)ay / 182.0f;
    tilt->y = (f32)ax / 182.0f;
}