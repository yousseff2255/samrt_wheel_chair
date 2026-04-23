#include "LED_interface.h"
#include "../../MCAL/GPIO/GPIO_interface.h"

void LED_Init(u8 Port, u8 Pin)
{
    GPIO_SetPinDirection(Port, Pin, GPIO_OUTPUT);
}

void LED_On(u8 Port, u8 Pin)
{
    GPIO_SetPinValue(Port, Pin, GPIO_HIGH);
}

void LED_Off(u8 Port, u8 Pin)
{
    GPIO_SetPinValue(Port, Pin, GPIO_LOW);
}

void LED_Toggle(u8 Port, u8 Pin)
{
    u8 current = GPIO_GetPinValue(Port, Pin);

    if(current == GPIO_HIGH)
        GPIO_SetPinValue(Port, Pin, GPIO_LOW);
    else
        GPIO_SetPinValue(Port, Pin, GPIO_HIGH);
}