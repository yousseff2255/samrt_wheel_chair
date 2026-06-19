#include "../../SERVICES/STD_TYPES.h"

/* Switch States */
#define SWITCH_PRESSED    0
#define SWITCH_RELEASED     1

void SWITCH_Init(u8 Port, u8 Pin);
u8 GetSwitchState(u8 Port, u8 Pin);
void SwitchPressed(u8 Port, u8 Pin);
void SwitchReleased(u8 Port, u8 Pin);