#ifndef PWM_CONFIG_H
#define PWM_CONFIG_H

/* Crystal Frequency */
#define F_CPU               8000000UL
/* Desired PWM Frequency in Hz */
#define PWM_DESIRED_FREQ    500UL
/* Timer2 Prescaler (1, 4, or 16) */
#define PWM_PRESCALER       16

/* PR2 Calculation: Compiled into a single number to save RAM */
#define PWM_PR2_VALUE       (u8)((F_CPU / (PWM_DESIRED_FREQ * 4 * PWM_PRESCALER)) - 1)

#endif