#ifndef UART_CONFIG_H
#define UART_CONFIG_H

/* Crystal Frequency in Hz */
#define UART_FOSC           10000000UL

/**
 * High Baud Rate Select (BRGH)
 * 1: High speed (uses Fosc/16) - More accurate for high baud rates
 * 0: Low speed (uses Fosc/64)
 */
#define UART_BRGH_CONFIG    1

/* Timeout limit to prevent the PIC from freezing if the Raspberry Pi disconnects */
#define UART_TIMEOUT        20000

#endif