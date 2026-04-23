#line 1 "E:/University/Spring 26/CIE 349/Labs/My Drivers/MCAL/GPIO/GPIO.c"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gpio/gpio_interface.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gpio/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 31 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gpio/gpio_interface.h"
void GPIO_SetPinDirection(u8 Port, u8 Pin, u8 Direction);
void GPIO_SetPinValue(u8 Port, u8 Pin, u8 Value);
u8 GPIO_GetPinValue(u8 Port, u8 Pin);
void GPIO_Init(void);
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gpio/gpio_private.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gpio/gpio_config.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gpio/../../services/bit_math.h"
#line 8 "E:/University/Spring 26/CIE 349/Labs/My Drivers/MCAL/GPIO/GPIO.c"
void GPIO_SetPinDirection(u8 Port, u8 Pin, u8 Direction)
{
 switch(Port)
 {
 case  0 :
 if(Direction ==  0 )
  ( ( (*((volatile u8*)0x85)) ) &= ~(1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x85)) ) |= (1U << (Pin)) ) ;
 break;

 case  1 :
 if(Direction ==  0 )
  ( ( (*((volatile u8*)0x86)) ) &= ~(1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x86)) ) |= (1U << (Pin)) ) ;
 break;

 case  2 :
 if(Direction ==  0 )
  ( ( (*((volatile u8*)0x87)) ) &= ~(1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x87)) ) |= (1U << (Pin)) ) ;
 break;

 case  3 :
 if(Direction ==  0 )
  ( ( (*((volatile u8*)0x88)) ) &= ~(1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x88)) ) |= (1U << (Pin)) ) ;
 break;

 case  4 :
 if(Direction ==  0 )
  ( ( (*((volatile u8*)0x89)) ) &= ~(1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x89)) ) |= (1U << (Pin)) ) ;
 break;

 default:
 break;
 }
}


void GPIO_SetPinValue(u8 Port, u8 Pin, u8 Value)
{
 switch(Port)
 {
 case  0 :
 if(Value ==  1 )
  ( ( (*((volatile u8*)0x05)) ) |= (1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x05)) ) &= ~(1U << (Pin)) ) ;
 break;

 case  1 :
 if(Value ==  1 )
  ( ( (*((volatile u8*)0x06)) ) |= (1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x06)) ) &= ~(1U << (Pin)) ) ;
 break;

 case  2 :
 if(Value ==  1 )
  ( ( (*((volatile u8*)0x07)) ) |= (1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x07)) ) &= ~(1U << (Pin)) ) ;
 break;

 case  3 :
 if(Value ==  1 )
  ( ( (*((volatile u8*)0x08)) ) |= (1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x08)) ) &= ~(1U << (Pin)) ) ;
 break;

 case  4 :
 if(Value ==  1 )
  ( ( (*((volatile u8*)0x09)) ) |= (1U << (Pin)) ) ;
 else
  ( ( (*((volatile u8*)0x09)) ) &= ~(1U << (Pin)) ) ;
 break;

 default:
 break;
 }
}


u8 GPIO_GetPinValue(u8 Port, u8 Pin)
{
 u8 Local_Value = 0;

 switch(Port)
 {
 case  0 :
 Local_Value =  ( (( (*((volatile u8*)0x05)) ) >> (Pin)) & 1U ) ;
 break;

 case  1 :
 Local_Value =  ( (( (*((volatile u8*)0x06)) ) >> (Pin)) & 1U ) ;
 break;

 case  2 :
 Local_Value =  ( (( (*((volatile u8*)0x07)) ) >> (Pin)) & 1U ) ;
 break;

 case  3 :
 Local_Value =  ( (( (*((volatile u8*)0x08)) ) >> (Pin)) & 1U ) ;
 break;

 case  4 :
 Local_Value =  ( (( (*((volatile u8*)0x09)) ) >> (Pin)) & 1U ) ;
 break;

 default:
 break;
 }

 return Local_Value;
}

void GPIO_Init(void)
{
  (*((volatile u8*)0x85))  =  0x00 ;
  (*((volatile u8*)0x86))  =  0xFF ;

  (*((volatile u8*)0x05))  =  0x00 ;
  (*((volatile u8*)0x06))  =  0x00 ;
}
