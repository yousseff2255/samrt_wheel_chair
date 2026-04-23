#ifndef UART_PRIVATE_H
#define UART_PRIVATE_H

#include "../REGISTERS/PIC16F877A_reg.h"

#define TX_PIN          6
#define RX_PIN          7

/* PIR1 Bits */
#define TXIF            4
#define RCIF            5

/* TXSTA Bits */
#define TXSTA_TXEN      5
#define TXSTA_BRGH      2
#define TXSTA_TRMT      1

/* RCSTA Bits */
#define RCSTA_SPEN      7
#define RCSTA_CREN      4
#define RCSTA_OERR      1

#endif