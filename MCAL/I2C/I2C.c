#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

#include "I2C_interface.h"
#include "I2C_private.h"
#include "I2C_config.h"

/**
 * Helper function to wait for the I2C operation to complete.
 */
static void I2C_Wait(void) {
    u16 timeout = 10000;
    while (GET_BIT(PIR1, SSPIF) == 0) {
        if (--timeout == 0) break;  // Prevent infinite loop
    }
    CLR_BIT(PIR1, SSPIF);
}

void I2C_Init(u32 baud) {
    /* 1. Set RC3 and RC4 as inputs for the MSSP module */
    SET_BIT(TRISC, SCL_PIN);
    SET_BIT(TRISC, SDA_PIN);

    /* 2. Configure SSPCON: Enable SSP and set Master Mode */
    // 0x28 = 0b00101000 (SSPEN=1, I2C Master Mode)
    SSPCON = 0x28;

    /* 3. Configure SSPSTAT: Slew rate control */
    // Standard speed (100kHz) usually has slew rate disabled (bit 7 = 1)
    SSPSTAT = 0x80;

    /* 4. Set Clock Speed using the formula */
    SSPADD = (u8)((I2C_FOSC / (4 * baud)) - 1);

    /* 5. Clear initial interrupt flag */
    CLR_BIT(PIR1, SSPIF);
}

void I2C_Start(void) {
    // No need to wait before Start if bus is idle
    SET_BIT(SSPCON2, SSPCON2_SEN); // Initiate Start
    I2C_Wait();                    // Wait for it to finish
}

void I2C_Restart(void) {
    SET_BIT(SSPCON2, SSPCON2_RSEN); // Initiate Repeated Start
    I2C_Wait();
}

void I2C_Stop(void) {
    SET_BIT(SSPCON2, SSPCON2_PEN);  // Initiate Stop
    I2C_Wait();
}

u8 I2C_Write(u8 Copy_u8Data) {
    SSPBUF = Copy_u8Data;
    I2C_Wait();
    // Return ACK status (0 = ACK received, 1 = NACK)
    return GET_BIT(SSPCON2, SSPCON2_ACKSTAT);
}

u8 I2C_Read(u8 ack_type) {
    u8 local_data;

    SET_BIT(SSPCON2, SSPCON2_RCEN); // 1. Enable Receive mode
    I2C_Wait();                     // 2. Wait for 8 bits to arrive

    local_data = SSPBUF;            // 3. Read data from buffer

    /* 4. Send Acknowledge (ACK) or Not-Acknowledge (NACK) */
    if (ack_type == I2C_ACK) {
        CLR_BIT(SSPCON2, SSPCON2_ACKDT); // 0 = ACK
    } else {
        SET_BIT(SSPCON2, SSPCON2_ACKDT); // 1 = NACK
    }

    SET_BIT(SSPCON2, SSPCON2_ACKEN); // Start the ACK sequence
    I2C_Wait();

    return local_data;
}