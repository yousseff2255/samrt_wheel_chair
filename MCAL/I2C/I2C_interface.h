#ifndef I2C_INTERFACE_H
#define I2C_INTERFACE_H

/* Macros for Acknowledge bit */
#define I2C_ACK     0
#define I2C_NACK    1

/* Function Prototypes */


void I2C_Init(u32 baud);

void I2C_Start(void);
void I2C_Restart(void);
void I2C_Stop(void);

u8 I2C_Write(u8 Copy_u8Data);
u8 I2C_Read(u8 ack_type);

#endif