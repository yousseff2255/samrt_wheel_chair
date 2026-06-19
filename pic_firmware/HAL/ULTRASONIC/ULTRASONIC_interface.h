#ifndef ULTRASONIC_INTERFACE_H
#define ULTRASONIC_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

void ULTRASONIC_Init(void);
u16  ULTRASONIC_GetDistance(void);   // Returns distance in cm

#endif