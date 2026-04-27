#ifndef MAX30100_INTERFACE_H
#define MAX30100_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

void MAX30100_Init(void);
void MAX30100_Reset(void);
u8   MAX30100_GetPartID(void);
void MAX30100_ClearFIFO(void);
void MAX30100_ReadRaw(u16 *ir, u16 *red);
u8   MAX30100_GetHeartRate(void);
u8   MAX30100_GetSpO2(u16 ir, u16 red);
u8   MAX30100_IsHRAlert(void);      /* Returns 1 if HR out of normal range */
u8   MAX30100_IsSpO2Alert(void);    /* Returns 1 if SpO2 below threshold */

#endif