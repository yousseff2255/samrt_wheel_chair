#ifndef ULTRASONIC_PRIVATE_H
#define ULTRASONIC_PRIVATE_H

#include "../../MCAL/REGISTERS/PIC16F877A_reg.h"

/* ── Trigger: RD5 (free GPIO) ───────────────────────────────────────────────── */
#define ULTRASONIC_TRIG_DIR     TRISD
#define ULTRASONIC_TRIG_PORT    PORTD
#define ULTRASONIC_TRIG_PIN     5

/* ── Echo: RB0 (INT / EXTI pin) ─────────────────────────────────────────────── */
#define ULTRASONIC_ECHO_DIR     TRISB
#define ULTRASONIC_ECHO_PIN     0

/* ── Echo state machine states ───────────────────────────────────────────────── */
#define ECHO_IDLE               0u
#define ECHO_STARTED            1u
#define ECHO_DONE               2u

#endif /* ULTRASONIC_PRIVATE_H */