#ifndef UART_INTERFACE_H
#define UART_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

void UART_Init(u32 baud);
void UART_SendByte(u8 Copy_u8Data);
u8   UART_ReceiveByte(void);
void UART_SendString(const char* Copy_pcString);
void UART_ReceiveString(char* buffer, u8 maxLen);
u8   UART_DataAvailable(void);
void UART_SendNum(uint16_t num);

#endif