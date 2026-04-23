#line 1 "E:/University/Spring 26/CIE 349/Labs/My Drivers/HAL/SWITCH/SWITCH.c"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/hal/switch/switch_interface.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/hal/switch/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 7 "e:/university/spring 26/cie 349/labs/my drivers/hal/switch/switch_interface.h"
void SWITCH_Init(u8 Port, u8 Pin);
u8 GetSwitchState(u8 Port, u8 Pin);
void SwitchPressed(u8 Port, u8 Pin);
void SwitchReleased(u8 Port, u8 Pin);
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/hal/switch/../../mcal/gpio/gpio_interface.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/hal/switch/../../mcal/gpio/../../services/std_types.h"
#line 31 "e:/university/spring 26/cie 349/labs/my drivers/hal/switch/../../mcal/gpio/gpio_interface.h"
void GPIO_SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void GPIO_SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GPIO_GetPinValue(u8 Port, u8 Pin);
void GPIO_Init(void);
#line 4 "E:/University/Spring 26/CIE 349/Labs/My Drivers/HAL/SWITCH/SWITCH.c"
void SWITCH_Init(u8 Port, u8 Pin)
{
 GPIO_SetPinDirection(Port, Pin,  1 );
}

u8 GetSwitchState(u8 Port, u8 Pin)
{
 u8 current = GPIO_GetPinValue(Port, Pin);

 return current;
}
