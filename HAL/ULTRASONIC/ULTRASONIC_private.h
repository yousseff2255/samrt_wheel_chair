#ifndef ULTRASONIC_PRIVATE_H
#define ULTRASONIC_PRIVATE_H

/* Echo = RB0 (Pin 33), Trigger = RB1 (Pin 34) */
#define ULTRASONIC_TRIG_DIR      TRISB1_bit
#define ULTRASONIC_TRIG_PORT     RB1_bit

#define ULTRASONIC_ECHO_DIR      TRISB0_bit
#define ULTRASONIC_ECHO_PORT     RB0_bit

#endif