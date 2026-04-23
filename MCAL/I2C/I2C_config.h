#ifndef I2C_CONFIG_H
#define I2C_CONFIG_H

/* * Define the Crystal Frequency (Fosc) in Hz.
 * This is used to calculate the Baud Rate (SSPADD).
 */
#define I2C_FOSC    8000000UL  // 8 MHz

/* * Default Baud Rate if not specified.
 */
#define I2C_DEFAULT_BAUD  100000UL // 100 kHz

#endif