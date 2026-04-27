#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "ULTRASONIC_interface.h"
#include "ULTRASONIC_private.h"
#include "ULTRASONIC_config.h"

void ULTRASONIC_Init(void) {
    ULTRASONIC_TRIG_DIR = 0; // Trigger Output
    ULTRASONIC_ECHO_DIR = 1; // Echo Input
    ULTRASONIC_TRIG_PORT = 0;

    /* OPTION_REG: Set TMR0 Prescaler to 1:256
       This allows the 8-bit timer to measure longer distances
       without overflowing immediately. */
    OPTION_REG = 0b00000111;
}

u16 ULTRASONIC_GetDistance(void) {
    u16 distance = 0;
    u32 timeout = 0;

    /* 1. Send 10us Trigger Pulse to RB1 */
    ULTRASONIC_TRIG_PORT = 1;
    Delay_us(10);
    ULTRASONIC_TRIG_PORT = 0;

    /* 2. Wait for Echo to START (RB0 goes HIGH) */
    timeout = 0;
    while (ULTRASONIC_ECHO_PORT == 0) {
        timeout++;
        if (timeout > 5000) return 400; // Return max if sensor disconnected
    }

    /* 3. Start Timing (Reset hardware TMR0) */
    TMR0 = 0;

    /* 4. Wait for Echo to END (RB0 goes LOW) */
    timeout = 0;
    while (ULTRASONIC_ECHO_PORT == 1) {
        timeout++;
        /* Safety break if pulse is way too long */
        if (timeout > 15000) break;
    }

    /* 5. Formula: Distance = Timer Ticks * (cm_per_tick)
       With 1:256 prescaler, each TMR0 tick is roughly 2cm. */
    distance = (u16)((TMR0 * 7) / 4);

    /* 6. PROTEUS STABILITY DELAY
       The sensor and simulation need time to 'rest' between pulses. */
    Delay_ms(80);

    return (distance == 0) ? 400 : distance;
}