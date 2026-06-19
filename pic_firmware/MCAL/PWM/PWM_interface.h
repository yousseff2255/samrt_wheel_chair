#ifndef PWM_INTERFACE_H
#define PWM_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

/* Initializes PWM1 with a pre-calculated PR2 value */
void PWM1_Init(u8 Copy_u8PR2Value);

/* Sets Duty Cycle (0 - 100) */
void PWM1_SetDutyCycle(u8 duty_percentage);

void PWM1_Stop(void);



void PWM2_Init(u8 Copy_u8PR2Value);

void PWM2_SetDutyCycle(u8 duty_percentage);

void PWM2_Stop(void);

#endif