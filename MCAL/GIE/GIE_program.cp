#line 1 "E:/University/Spring 26/CIE 349/Labs/My Drivers/MCAL/GIE/GIE_program.c"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gie/../../services/std_types.h"




typedef signed char s8;
typedef signed short int s16;
typedef signed long int s32;


typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned long int u32;


typedef float f32;
typedef double f64;
typedef long double f128;
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gie/../../services/bit_math.h"
#line 1 "e:/university/spring 26/cie 349/labs/my drivers/mcal/gie/gie_interface.h"




void GIE_voidEnable(void);


void GIE_voidDisable(void);
#line 9 "E:/University/Spring 26/CIE 349/Labs/My Drivers/MCAL/GIE/GIE_program.c"
void GIE_voidEnable(void) {
  ( ( *((volatile unsigned char*)0x000B) ) |= (1U << ( 7 )) ) ;
}

void GIE_voidDisable(void) {
  ( ( *((volatile unsigned char*)0x000B) ) &= ~(1U << ( 7 )) ) ;
}
