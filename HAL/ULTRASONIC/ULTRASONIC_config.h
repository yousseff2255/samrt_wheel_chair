#ifndef ULTRASONIC_CONFIG_H
#define ULTRASONIC_CONFIG_H

/* ── Crystal & Timer ───────────────────────────────────────────────────────── */
#define ULTRASONIC_FOSC             10000000UL

/* Must match TMR0_PRESCALER in TMR0_config.h  (1:32) */
#define ULTRASONIC_PRESCALER        32u

/* One TMR0 tick duration in microseconds
 *   tick_us = (4 / Fosc) * prescaler = (4 / 10 000 000) * 32 = 12.8 us      */
#define ULTRASONIC_TICK_US          12.8f

/* ── Physics ────────────────────────────────────────────────────────────────── */
/* Speed of sound at ~20 °C in cm/us */
#define ULTRASONIC_SOUND_SPEED      0.0343f

/* cm per tick = (tick_us * speed) / 2   (divide by 2: round-trip)
 *   = (12.8 * 0.0343) / 2 = 0.2195 cm                                        */
#define ULTRASONIC_CM_PER_TICK      ((ULTRASONIC_TICK_US * ULTRASONIC_SOUND_SPEED) / 2.0f)

/* ── Distance Limits ────────────────────────────────────────────────────────── */
#define ULTRASONIC_MAX_DISTANCE     400u   /* cm */
#define ULTRASONIC_WARN_DISTANCE    100u    /* cm */
#define ULTRASONIC_STOP_DISTANCE    40u    /* cm */

/* ── Overflow Guard ─────────────────────────────────────────────────────────── */
/*
 * HC-SR04 echo pulse can be up to 38 ms for 400 cm.
 * TMR0 overflows every:  256 ticks * 12.8 us = 3.277 ms
 * Overflows needed for 38 ms:  38 / 3.277 ≈ 11.6  → use 13 as safe ceiling.
 */
#define ULTRASONIC_MAX_OVERFLOWS    13u

#endif /* ULTRASONIC_CONFIG_H */