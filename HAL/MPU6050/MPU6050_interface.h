#ifndef MPU6050_INTERFACE_H
#define MPU6050_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

typedef struct {
    s16 x;   /* tan(tilt_X) * 100 — positive = tilted toward +Y */
    s16 y;   /* tan(tilt_Y) * 100 — positive = tilted toward +X */
} MPU6050_Tilt;
void MPU6050_Init(void);
void MPU6050_Calibrate(void);       /* call once after Init, sensor must be flat */
void MPU6050_Update(void);          /* call regularly — reads sensor + filters   */
void MPU6050_GetTilt(MPU6050_Tilt *tilt);
u8   MPU6050_IsWarning(void);       /* both use last Update() result — no extra I2C */
u8   MPU6050_IsFalling(void);

#endif