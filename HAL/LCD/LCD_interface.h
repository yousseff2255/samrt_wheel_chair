#ifndef LCD_INTERFACE_H
#define LCD_INTERFACE_H

#include "../../SERVICES/STD_TYPES.h"

/* Function Prototypes */
void Lcd_Init(void);
void Lcd_Cmd(u8 cmd);
void Lcd_Chr(u8 ch);
void Lcd_Out_Int(s16 val);
void Lcd_PrintString(const char* str); /* Bonus: added string support! */

/* Common Commands */
#define LCD_CLEAR           0x01
#define LCD_RETURN_HOME     0x02
#define LCD_CURSOR_OFF      0x0C

#endif