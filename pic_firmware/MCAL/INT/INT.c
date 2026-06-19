



#include <xc.h>
#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../TMR0/TMR0_private.h"
#include "../EXTI/EXTI_private.h"

extern void (*TMR0_CallBackFuncP)(void);
extern void (*EXTI_CallBackFuncP)(void);

void __interrupt() ISR(void) {

    /*
     * EXTI (RB0/INT) ? MUST be checked first.
     * The ultrasonic echo callback captures TMR0 at the exact falling edge.
     * Checking INTF before TMR0IF ensures the tick count is read BEFORE
     * the overflow callback increments Echo_Overflow, preventing an
     * off-by-one error when both flags are set simultaneously.
     */
    if (GET_BIT(INTCON, INTF) && GET_BIT(INTCON, INTE)) {
        CLR_BIT(INTCON, INTF);          /* clear flag BEFORE callback    */
        if (EXTI_CallBackFuncP != NULL_PTR)
            EXTI_CallBackFuncP();
    }

    /*
     * TMR0 overflow ? only service if TMR0IE is enabled.
     * The ULTRASONIC driver enables TMR0IE on the rising edge and
     * disables it on the falling edge, so this fires only during
     * an active echo pulse ? never spuriously.
     */
    if (GET_BIT(INTCON, TMR0IF) && GET_BIT(INTCON, TMR0IE)) {
        CLR_BIT(INTCON, TMR0IF);        /* clear flag BEFORE callback    */
        if (TMR0_CallBackFuncP != NULL_PTR)
            TMR0_CallBackFuncP();
    }
}
