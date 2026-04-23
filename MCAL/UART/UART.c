#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

#include "UART_interface.h"
#include "UART_private.h"
#include "UART_config.h"

void UART_Init(u32 baud) {
    /* 1. Pin Directions */
    CLR_BIT(TRISC, TX_PIN);
    SET_BIT(TRISC, RX_PIN);

    /* 2. Clear registers before configuring */
    TXSTA = 0x00;
    RCSTA = 0x00;

    /* 3. Baud Rate */
    #if UART_BRGH_CONFIG == 1
        SET_BIT(TXSTA, TXSTA_BRGH);
        SPBRG = (u8)((UART_FOSC / (16UL * baud)) - 1);
    #else
        CLR_BIT(TXSTA, TXSTA_BRGH);
        SPBRG = (u8)((UART_FOSC / (64UL * baud)) - 1);
    #endif

    /* 4. Enable Transmit and Receive */
    SET_BIT(TXSTA, TXSTA_TXEN);
    SET_BIT(RCSTA, RCSTA_SPEN);
    SET_BIT(RCSTA, RCSTA_CREN);
}

void UART_SendByte(u8 Copy_u8Data) {
    /* Wait until the Transmit Buffer is empty (TXIF is set) */
    while (GET_BIT(PIR1, TXIF) == 0);

    /* Load data into register to start transmission */
    TXREG = Copy_u8Data;
}

u8 UART_ReceiveByte(void) {
    // Clear overrun error if it occurred
    if (GET_BIT(RCSTA, RCSTA_OERR) == 1) {
        CLR_BIT(RCSTA, RCSTA_CREN);
        SET_BIT(RCSTA, RCSTA_CREN);
    }
    while (GET_BIT(PIR1, RCIF) == 0);
    return RCREG;
}

void UART_SendString(const char* Copy_pcString) {
    u32 i = 0;
    while (Copy_pcString[i] != '\0') {
        UART_SendByte(Copy_pcString[i]);
        i++;
    }
}

void UART_ReceiveString(char* buffer, u8 maxLen) {
    u8 i = 0;
    char c;
    while (i < maxLen - 1) {
        c = UART_ReceiveByte();
        if (c == '\n') break;
        buffer[i++] = c;
    }
    buffer[i] = '\0';
}