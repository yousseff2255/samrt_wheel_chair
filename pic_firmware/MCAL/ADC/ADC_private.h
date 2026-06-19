#ifndef ADC_PRIVATE_H
#define ADC_PRIVATE_H

#include "../REGISTERS/PIC16F877A_reg.h"

/* ADCON0 Bit Definitions */
#define ADCON0_ADON         0
#define ADCON0_GO_DONE      2
#define ADCON0_CHS0         3

/* ADCON1 Bit Definitions */
#define ADCON1_ADFM         7
#define ADC_ALL_ANALOG_MASK 0xF0

/* PIR1 Bits */
#define ADIF                6

#endif