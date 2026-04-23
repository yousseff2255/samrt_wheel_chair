#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "EXTI_interface.h"
#include "EXTI_private.h"

/* Global Function Pointer for the Callback */
void (*EXTI_CallBackFuncP)(void) = NULL_PTR;

void EXTI_Init(void) {

    //SET_BIT(INTCON, GIE);   // Enable Global interrupt
     
    /* 1. Set Sense Control (Edge Trigger) from Config */
    #if EXTI_SENSE_MODE == EXTI_RISING_EDGE
        SET_BIT(OPTION_REG, INTEDG);
    #else
        CLR_BIT(OPTION_REG, INTEDG);
    #endif
    
    SET_BIT(OPTION_REG, INTEDG);

    /* 2. Clear Flag and Enable EXTI */
    CLR_BIT(INTCON, INTF);
    SET_BIT(INTCON, INTE);
}

void EXTI_SetCallBack(void (*ptr)(void)) {
    if (ptr != NULL_PTR) {
        EXTI_CallBackFuncP = ptr;
    }
}

void EXTI_GlobalInterruptDisable(void){
  CLR_BIT(INTCON, GIE);
}

void  EXTI_GlobalInterruptEnable(void){
SET_BIT(INTCON, GIE);
 }


 void EXTI_ToggleEdge(void) {
    if (GET_BIT(OPTION_REG, INTEDG) == 1) {
        CLR_BIT(OPTION_REG, INTEDG);  // Switch to Falling
    } else {
        SET_BIT(OPTION_REG, INTEDG);  // Switch to Rising
    }
    CLR_BIT(INTCON, INTF);  // Clear flag after toggling to avoid false trigger
}