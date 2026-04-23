#ifndef PIC16F877A_REG_H
#define PIC16F877A_REG_H

#include "../../SERVICES/STD_TYPES.h"

/* GPIO */
#define TRISA       *((volatile u8*)0x85)
#define TRISB       *((volatile u8*)0x86)
#define TRISC       *((volatile u8*)0x87)
#define TRISD       *((volatile u8*)0x88)
#define TRISE       *((volatile u8*)0x89)
#define PORTA       *((volatile u8*)0x05)
#define PORTB       *((volatile u8*)0x06)
#define PORTC       *((volatile u8*)0x07)
#define PORTD       *((volatile u8*)0x08)
#define PORTE       *((volatile u8*)0x09)

/* Interrupts */
#define INTCON      *((volatile u8*)0x0B)
#define OPTION_REG  *((volatile u8*)0x81)
#define PIR1        *((volatile u8*)0x0C)

/* UART */
#define TXSTA       *((volatile u8*)0x98)
#define RCSTA       *((volatile u8*)0x18)
#define SPBRG       *((volatile u8*)0x99)
#define TXREG       *((volatile u8*)0x19)
#define RCREG       *((volatile u8*)0x1A)

/* I2C / MSSP */
#define SSPSTAT     *((volatile u8*)0x94)
#define SSPCON      *((volatile u8*)0x14)
#define SSPCON2     *((volatile u8*)0x91)
#define SSPBUF      *((volatile u8*)0x13)
#define SSPADD      *((volatile u8*)0x93)

/* ADC */
#define ADCON0      *((volatile u8*)0x1F)
#define ADCON1      *((volatile u8*)0x9F)
#define ADRESH      *((volatile u8*)0x1E)
#define ADRESL      *((volatile u8*)0x9E)

/* PWM / CCP */
#define CCP1CON     *((volatile u8*)0x17)
#define CCPR1L      *((volatile u8*)0x15)
#define CCP2CON     *((volatile u8*)0x1D)
#define CCPR2L      *((volatile u8*)0x1B)

/* Timers */
#define TMR0        *((volatile u8*)0x01)
#define T2CON       *((volatile u8*)0x12)
#define PR2         *((volatile u8*)0x92)

#endif