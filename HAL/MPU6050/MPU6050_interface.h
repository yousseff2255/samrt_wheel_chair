#ifndef MPU6050_INTERFACE_H
#define MPU6050_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

typedef struct {
    f32 x;  /* Tilt angle around X axis in degrees */
    f32 y;  /* Tilt angle around Y axis in degrees */
} MPU6050_Tilt;

void MPU6050_Init(void);
void MPU6050_GetTilt(MPU6050_Tilt* tilt);
u8   MPU6050_IsFalling(void);   /* Returns 1 if tilt exceeds cutoff threshold */
u8   MPU6050_IsWarning(void);   /* Returns 1 if tilt exceeds warning threshold */

#endif