#ifndef MOTOR_PRIVATE_H
#define MOTOR_PRIVATE_H

#include "../../MCAL/REGISTERS/PIC16F877A_reg.h"

/* Left Motor Truth Table (L298N)
 * IN1=1, IN2=0 → Forward
 * IN1=0, IN2=1 → Backward
 * IN1=0, IN2=0 → Stop
 */

/* Right Motor Truth Table (L298N)
 * IN3=1, IN4=0 → Forward
 * IN3=0, IN4=1 → Backward
 * IN3=0, IN4=0 → Stop
 */

#endif