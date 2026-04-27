#ifndef MAX30100_CONFIG_H
#define MAX30100_CONFIG_H

/* I2C Address */
#define MAX30100_I2C_ADDRESS        0x57

/* Operating Mode */
#define MAX30100_MODE_SPO2          0x03
#define MAX30100_MODE_HR_ONLY       0x02

/* SPO2 Config */
#define MAX30100_SPO2_HI_RES_EN     0x40
#define MAX30100_SPO2_SR_100HZ      0x00
#define MAX30100_SPO2_LED_PW_1600US 0x03

/* LED Current (~27.1mA) */
#define MAX30100_LED_CURRENT        0xAF

/* Buffer and peak detection */
#define SAMPLE_BUFFER_SIZE          32
#define PEAK_THRESHOLD              1000
#define MIN_PEAK_DISTANCE           5

/* Alert thresholds */
#define MAX30100_HR_LOW             50    /* BPM below this = alert */
#define MAX30100_HR_HIGH            120   /* BPM above this = alert */
#define MAX30100_SPO2_LOW           90    /* SpO2 below this = emergency */

#endif