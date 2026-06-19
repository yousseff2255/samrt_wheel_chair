#ifndef I2C_PRIVATE_H
#define I2C_PRIVATE_H

#include "../REGISTERS/PIC16F877A_reg.h"

#define SCL_PIN             3
#define SDA_PIN             4

/* SSPCON2 Bits */
#define SSPCON2_SEN         0
#define SSPCON2_RSEN        1
#define SSPCON2_PEN         2
#define SSPCON2_RCEN        3
#define SSPCON2_ACKEN       4
#define SSPCON2_ACKDT       5
#define SSPCON2_ACKSTAT     6

#endif