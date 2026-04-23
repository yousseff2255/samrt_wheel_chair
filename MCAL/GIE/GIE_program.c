#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "GIE_interface.h"


#define INTCON *((volatile unsigned char*)0x000B)
#define GIE    7

void GIE_voidEnable(void) {
    SET_BIT(INTCON, GIE);
}

void GIE_voidDisable(void) {
    CLR_BIT(INTCON, GIE);
}