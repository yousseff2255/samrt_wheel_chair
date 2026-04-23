#ifndef EXTI_PRIVATE_H
#define EXTI_PRIVATE_H

#include "../REGISTERS/PIC16F877A_reg.h"

/* INTCON Bits */
#define GIE         7
#define INTE        4
#define INTF        1

/* OPTION_REG Bits */
#define INTEDG      6

/* Sense Mode Macros */
#define EXTI_FALLING_EDGE   0
#define EXTI_RISING_EDGE    1

#endif