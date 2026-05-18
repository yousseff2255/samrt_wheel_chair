#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "I2C_interface.h"
#include "I2C_private.h"
#include "I2C_config.h"
#include <xc.h>

/* Waits for the MSSP module to finish its current hardware task */
static void I2C_Wait_Flag(void) {
    u16 timeout = 0;
    
    /* Using direct XC8 bitfield to guarantee we check the correct hardware flag */
    while (!PIR1bits.SSPIF) {
        timeout++;
        if (timeout > I2C_TIMEOUT) break; /* Emergency exit if sensor dies */
    }
    PIR1bits.SSPIF = 0; /* Clear the flag for the next operation */
}

/* ---------------------------------------------------------
 * DRIVER IMPLEMENTATION
 * --------------------------------------------------------- */

void I2C_Init(u32 baud) {
    /* 1. Set SCL and SDA as Inputs using native bitfields */
    TRISCbits.TRISC3 = 1;
    TRISCbits.TRISC4 = 1;

    /* 2. Reset registers */
    SSPCON  = 0x00;
    SSPCON2 = 0x00;
    
    /* 3. Slew rate control disabled for Standard Speed */
    SSPSTAT = 0x80;

    /* 4. Calculate and set baud rate based on Fosc */
    SSPADD = (u8)((I2C_FOSC / (4UL * baud)) - 1);

    /* 5. Enable I2C master mode */
    SSPCON = 0x28;

    /* 6. Clear interrupt flag */
    PIR1bits.SSPIF = 0;
}

void I2C_Start(void) {
    SSPCON2bits.SEN = 1;  /* Initiate Start condition */
    I2C_Wait_Flag();      /* Wait for Start to complete */
}

void I2C_Repeated_Start(void) {
    SSPCON2bits.RSEN = 1; /* Initiate Repeated Start */
    I2C_Wait_Flag();
}

void I2C_Stop(void) {
    SSPCON2bits.PEN = 1;  /* Initiate Stop condition */
    I2C_Wait_Flag();
}

u8 I2C_Write(u8 Copy_u8Data) {
    SSPBUF = Copy_u8Data; /* Load data into buffer to start sending */
    I2C_Wait_Flag();      /* Wait for transmission to complete */
    
    /* Return the ACK status (0 = Success/ACK, 1 = Fail/NACK) */
    return SSPCON2bits.ACKSTAT;
}

u8 I2C_Read(u8 ack_type) {
    u8 local_data;

    SSPCON2bits.RCEN = 1; /* 1. Enable Receive mode */
    I2C_Wait_Flag();      /* 2. Wait for 8 bits to shift in */

    local_data = SSPBUF;  /* 3. Extract the received data */

    /* 4. Set the Acknowledge bit we want to send back */
    if (ack_type == I2C_ACK) {
        SSPCON2bits.ACKDT = 0; /* 0 = ACK */
    } else {
        SSPCON2bits.ACKDT = 1; /* 1 = NACK */
    }

    SSPCON2bits.ACKEN = 1; /* 5. Transmit the ACK/NACK bit */
    I2C_Wait_Flag();

    return local_data;
}