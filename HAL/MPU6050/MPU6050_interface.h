#ifndef MPU6050_INTERFACE_H
#define MPU6050_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

typedef struct {
    f32 x;
    f32 y;
} MPU6050_Tilt;

/* Function Prototypes */
void MPU6050_Init(void);
void MPU6050_GetTilt(MPU6050_Tilt* tilt);
u8   MPU6050_IsWarning(void);
u8   MPU6050_IsFalling(void);

#endif