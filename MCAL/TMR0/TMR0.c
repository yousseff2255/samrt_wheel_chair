#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

#include "TMR0_interface.h"
#include "TMR0_private.h"
#include "TMR0_config.h"


u8 TMR0_PreloadValue = 0;

void (*TMR0_CallBackFuncP)(void) = NULL_PTR;

void TMR0_Init(void){
    //SET_BIT(INTCON, GIE);  // Enable Global interrupt

    /* 1. Select Internal Clock Source (Fosc/4) */
    CLR_BIT(OPTION_REG, T0CS);

    /* 2. Assign Prescaler to Timer0 (PSA = 0) */
    CLR_BIT(OPTION_REG, PSA);


    /* 3. Set Prescaler to 1:256 (0b111)
     First: Clear the bottom 3 bits (Masking)*/
    OPTION_REG &= 0xF8;         // 0b11111000

    // Second: Set the bits
    OPTION_REG |= TMR0_PRESCALER;

    /* 4. Clear the Timer Register and Flag */
    TMR0 = 0;
    CLR_BIT(INTCON, TMR0IF);
}

void TMR0_Start(){
SET_BIT(INTCON, TMR0IE);
}
void TMR0_Stop(){
CLR_BIT(INTCON, TMR0IE);}



void TMR0_reset(void) {
    TMR0 = TMR0_PreloadValue;        // Reset hardware register to preload value

}

void TMR0_SetCallBack(void(*CallBackFunc)(void)){
     if(CallBackFunc!=NULL_PTR){
       TMR0_CallBackFuncP =CallBackFunc;
     }
}



void TMR0_SetPreloadValue(u8 Value) {
    TMR0_PreloadValue = Value;
    TMR0 = Value;
}

u8 TMR0_GetPreloadValue(void) {
    return TMR0_PreloadValue;
}