#include <xc.h>
#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "GIE_interface.h"



void GIE_voidEnable(void) {
    INTCONbits.GIE = 1;
}

void GIE_voidDisable(void) {
    INTCONbits.GIE = 0;
}