#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

#include "../../MCAL/TMR0/TMR0_interface.h"
#include "../../MCAL/EXTI/EXTI_interface.h"
#include "../../MCAL/GPIO/GPIO_interface.h"

#include "ULTRASONIC_interface.h"
#include "ULTRASONIC_private.h"
#include "ULTRASONIC_config.h"

/* State machine for echo measurement */
typedef enum {
    ECHO_IDLE,
    ECHO_STARTED,
    ECHO_DONE
} ECHO_State;

static volatile ECHO_State Echo_State = ECHO_IDLE;
static volatile u8 Echo_TickCount    = 0;
static volatile u8 Echo_Overflow     = 0;

/* Callback: fires on every EXTI edge */
static void ULTRASONIC_EchoCallback(void) {
    if (Echo_State == ECHO_IDLE) {
        /* Rising edge detected — start counting */
        TMR0_SetPreloadValue(0);
        TMR0_Start();
        Echo_TickCount = 0;
        Echo_Overflow  = 0;
        Echo_State     = ECHO_STARTED;
        EXTI_ToggleEdge();          // Now listen for falling edge
    }
    else if (Echo_State == ECHO_STARTED) {
        /* Falling edge detected — stop counting */
        TMR0_Stop();
        Echo_TickCount = TMR0_GetPreloadValue();
        Echo_State     = ECHO_DONE;
        EXTI_ToggleEdge();          // Reset back to rising edge
    }
}

/* ── Callback: fires on every TMR0 overflow ── */
static void ULTRASONIC_TimerCallback(void) {
    if (Echo_State == ECHO_STARTED) {
        Echo_Overflow++;
        /* If overflow too many times, object is out of range */
        if (Echo_Overflow > 4) {
            TMR0_Stop();
            Echo_State = ECHO_DONE;
            Echo_TickCount = 0xFF;  // Sentinel for out of range
        }
    }
}

void ULTRASONIC_Init(void) {
    /* 1. TRIG as output, ECHO as input */
    CLR_BIT(ULTRASONIC_TRIG_DIR, ULTRASONIC_TRIG_PIN);
    SET_BIT(ULTRASONIC_ECHO_DIR, ULTRASONIC_ECHO_PIN);

    /* 2. TRIG starts LOW */
    CLR_BIT(ULTRASONIC_TRIG_PORT, ULTRASONIC_TRIG_PIN);

    /* 3. Register callbacks */
    EXTI_SetCallBack(ULTRASONIC_EchoCallback);
    TMR0_SetCallBack(ULTRASONIC_TimerCallback);

    /* 4. Init EXTI on rising edge first */
    EXTI_Init();
}

u16 ULTRASONIC_GetDistance(void) {
    u16 distance = 0;

    /* 1. Reset state */
    Echo_State = ECHO_IDLE;

    /* 2. Send 10us TRIG pulse */
    SET_BIT(ULTRASONIC_TRIG_PORT, ULTRASONIC_TRIG_PIN);
   
    Delay_us(10);
    CLR_BIT(ULTRASONIC_TRIG_PORT, ULTRASONIC_TRIG_PIN);

    /* 3. Wait for measurement to complete with timeout */
    u16 timeout = 60000;
    while (Echo_State != ECHO_DONE) {
        if (--timeout == 0) return ULTRASONIC_MAX_DISTANCE;
    }

    /* 4. Calculate distance */
    if (Echo_TickCount == 0xFF) {
        return ULTRASONIC_MAX_DISTANCE;  // Out of range
    }

    distance = (u16)(Echo_TickCount * ULTRASONIC_CM_PER_TICK);

    /* 5. Clamp to max */
    if (distance > ULTRASONIC_MAX_DISTANCE) {
        distance = ULTRASONIC_MAX_DISTANCE;
    }

    return distance;
}