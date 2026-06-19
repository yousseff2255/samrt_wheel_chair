#ifndef EXTI_INTERFACE_H
#define EXTI_INTERFACE_H





void EXTI_Init(void);

void EXTI_SetCallBack(void (*ptr)(void));
void EXTI_GlobalInterruptDisable(void);
void  EXTI_GlobalInterruptEnable(void);

void EXTI_ToggleEdge(void);


#endif