#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../TMR0/TMR0_interface.h"

/* External variable from TMR0.c */
extern u8 TMR0_PreloadValue;

/* Flags for main.c */
volatile u8 TMR0_Flag = 0;
volatile u8 EXTI_Flag = 0;

void interrupt() {
    /* 1. Timer0 */
    if (GET_BIT(INTCON, TMR0IF) == 1) {
        TMR0 = TMR0_PreloadValue; /* Direct access saves stack */
        CLR_BIT(INTCON, TMR0IF);
        TMR0_Flag = 1;
    }

    /* 2. External Interrupt */
    if (GET_BIT(INTCON, INTF) == 1) {
        CLR_BIT(INTCON, INTF);
        EXTI_Flag = 1;
    }
}