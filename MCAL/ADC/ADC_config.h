#ifndef ADC_CONFIG_H
#define ADC_CONFIG_H

/**
 * ADC Clock Select
 * 00: Fosc/2
 * 01: Fosc/8
 * 10: Fosc/32
 * 11: Frc (Internal RC oscillator)
 */
#define ADC_CLOCK_SELECT    0b10

/**
 * Result Format
 * 1: Right Justified (Easier for 10-bit math)
 * 0: Left Justified
 */
#define ADC_RESULT_FORMAT   1


#define ADC_ANALOG_CHANNELS   ADC_ALL_ANALOG 

#endif