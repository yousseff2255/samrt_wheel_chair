#ifndef TMR0_INTERFACE_H
#define TMR0_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"






void TMR0_Init(void);

void TMR0_Start(void);
void TMR0_Stop(void);

void TMR0_SetPreloadValue(u8 Value);
void TMR0_reset(void);

void TMR0_SetCallBack(void (*CallBackFunc)(void));

u8 TMR0_GetPreloadValue(void);


#endif