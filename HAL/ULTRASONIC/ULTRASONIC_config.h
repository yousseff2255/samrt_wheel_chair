#ifndef ULTRASONIC_CONFIG_H
#define ULTRASONIC_CONFIG_H

/* Crystal Frequency */
#define ULTRASONIC_FOSC         10000000UL

/* TMR0 Prescaler used (must match TMR0_config.h) */
#define ULTRASONIC_PRESCALER    256

/* One TMR0 tick in microseconds */
/* Tick = (4 / Fosc) * Prescaler = (4 / 10000000) * 256 = 102.4 us */
#define ULTRASONIC_TICK_US      102.4f

/* Speed of sound in cm/us */
#define ULTRASONIC_SOUND_SPEED  0.0343f

/* Distance per tick = (tick_us * speed) / 2 */
#define ULTRASONIC_CM_PER_TICK  ((ULTRASONIC_TICK_US * ULTRASONIC_SOUND_SPEED) / 2.0f)

/* Maximum reliable distance in cm */
#define ULTRASONIC_MAX_DISTANCE 400u

/* Warning threshold in cm (first level alert) */
#define ULTRASONIC_WARN_DISTANCE 50u

/* Hard stop threshold in cm (second level alert) */
#define ULTRASONIC_STOP_DISTANCE 20u


/* Comment this out when building for real hardware */
#define SIMULATION

#endif