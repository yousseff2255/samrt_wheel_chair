#include "SWITCH_interface.h"
#include "../../MCAL/GPIO/GPIO_interface.h"

void SWITCH_Init(u8 Port, u8 Pin)
{
    GPIO_SetPinDirection(Port, Pin, GPIO_INPUT);
}

u8 GetSwitchState(u8 Port, u8 Pin)
{
    u8 current = GPIO_GetPinValue(Port, Pin);

   return current;
}
