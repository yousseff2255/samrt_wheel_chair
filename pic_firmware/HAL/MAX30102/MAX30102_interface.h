#ifndef MAX30102_INTERFACE_H
#define MAX30102_INTERFACE_H

#include <stdint.h>
#include "../../SERVICES/STD_TYPES.h"

typedef struct {
    uint8_t bpm;           /* Changed u8 to uint8_t for standard compatibility */
    uint8_t spo2;
    uint8_t fingerDetected;
    int16_t irAC;          /* Filtered Pulse Signal */
    int16_t redAC;
} MAX30102_Result_t;

typedef enum {
    MAX30102_OK = 0,
    MAX30102_ERR
} MAX30102_Status_t;

MAX30102_Status_t MAX30102_Init(void);
void MAX30102_Update(void);
void MAX30102_GetResult(MAX30102_Result_t *res);

#endif