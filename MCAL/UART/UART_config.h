                                                #ifndef UART_CONFIG_H
#define UART_CONFIG_H

/* Crystal Frequency in Hz */
#define UART_FOSC           8000000UL

/**
 * Default Baud Rate
 * Common values: 9600, 19200, 38400, 57600, 115200
 */
#define UART_DEFAULT_BAUD   9600

/**
 * High Baud Rate Select (BRGH)
 * 1: High speed (uses Fosc/16) - More accurate for high baud rates
 * 0: Low speed (uses Fosc/64)
 */
#define UART_BRGH_CONFIG    1

#endif