#line 1 "E:/University/Spring 26/CIE 349/Labs/My Drivers/MCAL/ADC/ADC.c"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/adc/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/adc/../../services/bit_math.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/adc/adc_interface.h"
#line 14 "e:/university/spring 26/cie 349/labs/my drivers/mcal/adc/adc_interface.h"
void ADC_Init(void);
u16 ADC_GetChannelValue(u8 Copy_u8Channel);
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/adc/adc_private.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/adc/adc_config.h"
#line 8 "E:/University/Spring 26/CIE 349/Labs/My Drivers/MCAL/ADC/ADC.c"
void ADC_Init(void) {


  *((volatile u8*)0x85)  |= 0x01;


 if ( 1  == 1) {
  ( ( *((volatile u8*)0x9F) ) |= (1U << ( 7 )) ) ;
 } else {
  ( ( *((volatile u8*)0x9F) ) &= ~(1U << ( 7 )) ) ;
 }
  *((volatile u8*)0x9F)  &= 0xF0;


  *((volatile u8*)0x1F)  = ( 0b10  << 6);
  ( ( *((volatile u8*)0x1F) ) |= (1U << ( 0 )) ) ;
}

u16 ADC_GetChannelValue(u8 Copy_u8Channel) {
 u16 Local_u16Result = 0;
 volatile u8 Local_u8Delay;



  *((volatile u8*)0x1F)  &= 0xC7;

  *((volatile u8*)0x1F)  |= (Copy_u8Channel << 3);



 for(Local_u8Delay = 0; Local_u8Delay < 30; Local_u8Delay++) {

 }


  ( ( *((volatile u8*)0x1F) ) |= (1U << ( 2 )) ) ;



 while ( ( (( *((volatile u8*)0x1F) ) >> ( 2 )) & 1U )  == 1);


 if ( 1  == 1) {

 Local_u16Result = ((u16) *((volatile u8*)0x1E)  << 8) |  *((volatile u8*)0x9E) ;
 } else {
 Local_u16Result = ((u16) *((volatile u8*)0x1E)  << 2) | ( *((volatile u8*)0x9E)  >> 6);
 }

 return Local_u16Result;
}
