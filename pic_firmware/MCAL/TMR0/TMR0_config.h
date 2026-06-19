#ifndef TMR0_CONFIG_H
#define TMR0_CONFIG_H

/*
 * Prescaler bits for OPTION_REG[PS2:PS0]
 *
 * 000 -> 1:2
 * 001 -> 1:4
 * 010 -> 1:8
 * 011 -> 1:16
 * 100 -> 1:32   <-- chosen: tick = (4/10MHz)*32 = 12.8 us
 * 101 -> 1:64
 * 110 -> 1:128
 * 111 -> 1:256
 *
 * MUST match ULTRASONIC_PRESCALER = 32 in ULTRASONIC_config.h
 */
#define TMR0_PRESCALER   0b100   /* 1:32 */

#endif /* TMR0_CONFIG_H */