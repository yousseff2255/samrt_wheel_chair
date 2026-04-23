#ifndef ULTRASONIC_PRIVATE_H
#define ULTRASONIC_PRIVATE_H

#include "../../MCAL/REGISTERS/PIC16F877A_reg.h"

#ifdef SIMULATION
    /* GUR03 — Single SIG pin on RB0 */
    #define ULTRASONIC_SIG_DIR      TRISB
    #define ULTRASONIC_SIG_PORT     PORTB
    #define ULTRASONIC_SIG_PIN      0

#else
    /* HC-SR04 — Separate TRIG and ECHO for real hardware */
    #define ULTRASONIC_TRIG_DIR     TRISD
    #define ULTRASONIC_TRIG_PORT    PORTD
    #define ULTRASONIC_TRIG_PIN     0

    #define ULTRASONIC_ECHO_DIR     TRISB
    #define ULTRASONIC_ECHO_PIN     0
#endif

#endif