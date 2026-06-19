#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

#include "BUZZER_interface.h"
#include "BUZZER_private.h"
#include "BUZZER_config.h"
#include <xc.h>

void BUZZER_Init(void) {
    CLR_BIT(BUZZER_DIR, BUZZER_PIN);   // Set as output
    CLR_BIT(BUZZER_PORT, BUZZER_PIN);  // Start OFF
}

void BUZZER_On(void) {
    SET_BIT(BUZZER_PORT, BUZZER_PIN);
}

void BUZZER_Off(void) {
    CLR_BIT(BUZZER_PORT, BUZZER_PIN);
}