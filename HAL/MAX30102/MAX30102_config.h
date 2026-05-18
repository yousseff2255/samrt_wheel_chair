#ifndef MAX30102_CONFIG_H
#define MAX30102_CONFIG_H

/* PIC16F877A @ 10MHz - Guarded to prevent redefinition errors */
#ifndef _XTAL_FREQ
    #define _XTAL_FREQ 10000000UL
#endif

/* I2C Mapping */
#define MAX30102_I2C_START()            I2C_Start()
#define MAX30102_I2C_STOP()             I2C_Stop()
#define MAX30102_I2C_REPEATED_START()   I2C_Repeated_Start()
#define MAX30102_I2C_SEND(data)         I2C_Write(data)
#define MAX30102_I2C_READ(ack)          I2C_Read(ack)

/* LED Current Scaling */
#define MAX30102_RED_PA                 0x24
#define MAX30102_IR_PA                  0x24
#define MAX30102_FINGER_THRESHOLD       5000UL

#endif