#ifndef MOTOR_INTERFACE_H
#define MOTOR_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

void MOTOR_Init(void);
void MOTOR_Forward(void);
void MOTOR_Backward(void);
void MOTOR_Left(void);
void MOTOR_Right(void);
void MOTOR_Stop(void);

#endif