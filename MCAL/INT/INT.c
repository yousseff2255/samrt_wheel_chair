#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../TMR0/TMR0_private.h"  //
#include "../EXTI/EXTI_private.h"
#include "../TMR0/TMR0_interface.h"

/* Borrow the function pointers from the other drivers */
extern void (*TMR0_CallBackFuncP)(void);
extern void (*EXTI_CallBackFuncP)(void);

void interrupt() {
    /* 1. Timer0 Dispatcher */
    if (GET_BIT(INTCON, TMR0IF) == 1) {
        TMR0 = TMR0_GetPreloadValue();     // Set initial value
        CLR_BIT(INTCON,TMR0IF); // Clear Flag

        if (TMR0_CallBackFuncP != NULL_PTR) {
            TMR0_CallBackFuncP();
        }
    }

    /* 2. External Interrupt Dispatcher  */
    if (GET_BIT(INTCON, INTF) == 1) {
        CLR_BIT(INTCON, INTF); // Clear Flag immediately

        if (EXTI_CallBackFuncP != NULL_PTR) {
            EXTI_CallBackFuncP();
        }
        }

}