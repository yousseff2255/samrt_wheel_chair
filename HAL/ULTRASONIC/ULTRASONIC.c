#include <xc.h>
#define _XTAL_FREQ 10000000UL

#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "ULTRASONIC_interface.h"
#include "ULTRASONIC_private.h"
#include "ULTRASONIC_config.h"

void ULTRASONIC_Init(void) {
    /* 1. Setup Trigger and Echo Pins */
    CLR_BIT(ULTRASONIC_TRIG_DIR,  ULTRASONIC_TRIG_PIN);
    CLR_BIT(ULTRASONIC_TRIG_PORT, ULTRASONIC_TRIG_PIN);
    SET_BIT(ULTRASONIC_ECHO_DIR, ULTRASONIC_ECHO_PIN);

    /* 2. Setup Timer1 for 16-bit Polling (No Interrupts!)
     * 1:1 Prescaler. At 10MHz, 1 tick = 0.4 microseconds. */
    T1CON = 0x00; 
    

}

u16 ULTRASONIC_GetDistance(void) {
    u16 ticks = 0;
    u16 timeout = 0;
    float distance = 0;

    /* 1. CLONE BUG FIX: Force Echo pin LOW if stuck HIGH from a missed ping */
    if (GET_BIT(PORTB, ULTRASONIC_ECHO_PIN) == 1) {
        CLR_BIT(ULTRASONIC_ECHO_DIR, ULTRASONIC_ECHO_PIN);  /* Set Output */
        CLR_BIT(PORTB, ULTRASONIC_ECHO_PIN);                /* Drive LOW */
        __delay_ms(1);
        SET_BIT(ULTRASONIC_ECHO_DIR, ULTRASONIC_ECHO_PIN);  /* Set Input */
    }

    /* 2. Send 10us Trigger Pulse */
    SET_BIT(ULTRASONIC_TRIG_PORT, ULTRASONIC_TRIG_PIN);
    __delay_us(10);
    CLR_BIT(ULTRASONIC_TRIG_PORT, ULTRASONIC_TRIG_PIN);

    /* 3. Wait for Echo to go HIGH (Ping sent) */
    timeout = 0;
    while (GET_BIT(PORTB, ULTRASONIC_ECHO_PIN) == 0) {
        __delay_us(1);
        if (++timeout > 10000) {
            return ULTRASONIC_MAX_DISTANCE; /* Error: Sensor didn't fire */
        }
    }

    /* 4. Start Timer1 immediately */
    TMR1H = 0;
    TMR1L = 0;
    SET_BIT(T1CON, 0); /* TMR1ON = 1 */

    /* 5. Wait for Echo to go LOW (Ping returned) */
    while (GET_BIT(PORTB, ULTRASONIC_ECHO_PIN) == 1) {
        /* Read 16-bit timer safely */
        ticks = (TMR1H << 8) | TMR1L;
        
        /* If timer exceeds 60,000 ticks (~411 cm), force timeout */
        if (ticks > 60000) {
            CLR_BIT(T1CON, 0); /* TMR1ON = 0 */
            return ULTRASONIC_MAX_DISTANCE;
        }
    }

    /* 6. Stop timer and capture final ticks */
    CLR_BIT(T1CON, 0); /* TMR1ON = 0 */
    ticks = (TMR1H << 8) | TMR1L;

    /* 7. Calculate Distance
     * 1 Tick = 0.4 us. Sound = 0.0343 cm/us.
     * Distance = (Ticks * 0.4 * 0.0343) / 2 = Ticks * 0.00686 
     */
    distance = (float)ticks * 0.00686f;

    if (distance > ULTRASONIC_MAX_DISTANCE) {
        return ULTRASONIC_MAX_DISTANCE;
    }
    return (u16)distance;
}