#ifndef TMR0_PRIVATE_H
#define TMR0_PRIVATE_H

#include "../REGISTERS/PIC16F877A_reg.h"

/* OPTION_REG Bits */
#define PS0         0
#define PS1         1
#define PS2         2
#define PSA         3
#define T0CS        5
#define T0SE        4



/* Prescaler Options */
#define PRESCALER_2     0b000
#define PRESCALER_4     0b001
#define PRESCALER_8     0b010
#define PRESCALER_16    0b011
#define PRESCALER_32    0b100
#define PRESCALER_64    0b101
#define PRESCALER_128   0b110
#define PRESCALER_256   0b111

extern u8 TMR0_PreloadValue;

#endif