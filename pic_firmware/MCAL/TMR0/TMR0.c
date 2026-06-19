
#include <xc.h>
#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "TMR0_interface.h"
#include "TMR0_private.h"
#include "TMR0_config.h"

/* Callback pointer ? called by ISR on every TMR0 overflow */
void (*TMR0_CallBackFuncP)(void) = NULL_PTR;

void TMR0_Init(void) {
    /*
     * OPTION_REG layout (relevant bits):
     *  bit7: RBPU   ? leave alone
     *  bit6: INTEDG ? leave alone (EXTI uses this)
     *  bit5: T0CS   = 0  internal instruction clock
     *  bit4: T0SE   = 0  irrelevant (internal clock)
     *  bit3: PSA    = 0  prescaler assigned to TMR0
     *  bit2-0: PS   = TMR0_PRESCALER (from config)
     *
     * We ONLY touch bits 5,4,3,2,1,0 ? preserving RBPU and INTEDG.
     */
    OPTION_REG &= 0b11000000;              /* clear T0CS,T0SE,PSA,PS[2:0]  */
    OPTION_REG |= (0b00000000 | TMR0_PRESCALER); /* T0CS=0,PSA=0 + prescaler     */

    TMR0 = 0;
    CLR_BIT(INTCON, TMR0IF);
    /* TMR0IE is NOT enabled here ? ULTRASONIC driver enables it on demand */
}

void TMR0_Start(void) {
    TMR0 = 0;
    CLR_BIT(INTCON, TMR0IF);
    SET_BIT(INTCON, TMR0IE);
}

void TMR0_Stop(void) {
    CLR_BIT(INTCON, TMR0IE);
    CLR_BIT(INTCON, TMR0IF);
}

void TMR0_SetCallBack(void (*CallBackFunc)(void)) {
    if (CallBackFunc != NULL_PTR) {
        TMR0_CallBackFuncP = CallBackFunc;
    }
}
