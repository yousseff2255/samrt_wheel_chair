#ifndef TMR0_INTERFACE_H
#define TMR0_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

extern u8 TMR0_PreloadValue;   /* add this */

void TMR0_Init(void);
void TMR0_Start(void);
void TMR0_Stop(void);
void TMR0_SetPreloadValue(u8 Value);
void TMR0_reset(void);
u8 TMR0_GetPreloadValue(void);
void TMR0_SetCallBack(void (*CallBackFunc)(void));

#endif