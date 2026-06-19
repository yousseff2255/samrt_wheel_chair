#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "UART_interface.h"
#include "UART_private.h"
#include "UART_config.h"
#include <xc.h>

void UART_Init(u32 baud) {
    /* 1. Pin Directions */
    TRISCbits.TRISC6 = 0;   /* TX output */
    TRISCbits.TRISC7 = 1;   /* RX input */

    /* 2. Clear registers */
    TXSTA = 0x00;
    RCSTA = 0x00;

    /* 3. Baud Rate */
    #if UART_BRGH_CONFIG == 1
        TXSTAbits.BRGH = 1;
        SPBRG = (u8)((UART_FOSC / (16UL * baud)) - 1);
    #else
        TXSTAbits.BRGH = 0;
        SPBRG = (u8)((UART_FOSC / (64UL * baud)) - 1);
    #endif

    /* 4. Enable */
    TXSTAbits.TXEN  = 1;
    RCSTAbits.SPEN  = 1;
    RCSTAbits.CREN  = 1;
}

void UART_SendByte(u8 Copy_u8Data) {
    u16 timeout = 0;
    /* Wait for Transmit Shift Register to be empty, but escape if it hangs */
    while (!TXSTAbits.TRMT) {
        timeout++;
        if (timeout > UART_TIMEOUT) break; 
    }
    TXREG = Copy_u8Data;
}

u8 UART_ReceiveByte(void) {
    u16 timeout = 0;

    /* Clear Overrun Error (OERR) to prevent hardware lockup */
    if (RCSTAbits.OERR) {
        RCSTAbits.CREN = 0;
        RCSTAbits.CREN = 1;
    }

    /* Wait for a byte to arrive, escape if the sender disconnects */
    while (!PIR1bits.RCIF) {
        timeout++;
        if (timeout > UART_TIMEOUT) {
            return 0; /* Return NULL character on timeout */
        }
    }
    return RCREG;
}

void UART_SendString(const char* Copy_pcString) {
    while (*Copy_pcString) {
        UART_SendByte(*Copy_pcString++);
    }
}

void UART_ReceiveString(char* buffer, u8 maxLen) {
    u8   i = 0;
    char c = 0;
    
    while (i < maxLen - 1) {
        c = UART_ReceiveByte();
        
        /* Break if timeout occurred OR if we hit a newline/carriage return */
        if (c == 0) break;   
        if (c == '\n' || c == '\r') break; 
        
        buffer[i++] = c;
    }
    buffer[i] = '\0'; /* Null-terminate the string */
}

u8 UART_DataAvailable(void) {
    return PIR1bits.RCIF;
}

void UART_SendNum(uint16_t num) {
    char buf[6];
    uint8_t i = 0;
    
    if (num == 0) {
        UART_SendByte('0');
        return;
    }
    
    while (num > 0) {
        buf[i++] = '0' + (num % 10);
        num /= 10;
    }
    
    /* Reverse the buffer to print in correct order */
    uint8_t j;
    for (j = i; j > 0; j--) {
        UART_SendByte(buf[j-1]);
    }
}