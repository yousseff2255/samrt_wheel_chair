#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "../../MCAL/I2C/I2C_interface.h"

#include "LCD_interface.h"
#include "LCD_private.h"
#include "LCD_config.h"
#include <xc.h>

#define _XTAL_FREQ 10000000UL /* Needed for __delay_ms inside the driver */

/* Timing constants ? tune these down as low as stable */
#define LCD_EN_PULSE_US     1       /* Enable pulse width  */
#define LCD_CMD_US          50      /* Normal command wait */
#define LCD_CLEAR_MS        2       /* Clear/Home needs longer */

static void Lcd_SendNibble(u8 nibble) {
    I2C_Write(nibble | EN_BIT);
    __delay_us(LCD_EN_PULSE_US);
    I2C_Write(nibble);
    __delay_us(LCD_EN_PULSE_US);
}

static void Lcd_I2C_Write(u8 dat, u8 rs_mode) {
    u8 hi = (dat & 0xF0) | rs_mode | BL_BIT;
    u8 lo = ((dat << 4) & 0xF0) | rs_mode | BL_BIT;

    I2C_Start();
    I2C_Write(LCD_I2C_ADDRESS);
    Lcd_SendNibble(hi);
    Lcd_SendNibble(lo);
    I2C_Stop();
}

void Lcd_Cmd(u8 cmd) {
    Lcd_I2C_Write(cmd, 0);
    /* Only Clear and Return Home need long delay */
    if (cmd == LCD_CLEAR || cmd == 0x02)
        __delay_ms(LCD_CLEAR_MS);
    else
        __delay_us(LCD_CMD_US);
}

void Lcd_Chr(u8 ch) {
    Lcd_I2C_Write(ch, RS_BIT);
    __delay_us(LCD_CMD_US);   /* No delay_ms here */
}

void Lcd_PrintString(const char* str) {
    while (*str)
        Lcd_Chr(*str++);
}

/* Faster int print ? skips leading zeros */
void Lcd_Init(void) {
    __delay_ms(50);
    
    /* Hardware Reset Sequence for HD44780 */
    Lcd_SendNibble(0x30 | BL_BIT); 
    __delay_ms(5);
    Lcd_SendNibble(0x30 | BL_BIT);
    __delay_us(150);
    Lcd_SendNibble(0x30 | BL_BIT);
    __delay_us(150);
    Lcd_SendNibble(0x20 | BL_BIT); /* Switch to 4-bit mode */
    __delay_ms(2);

    /* Configuration */
    Lcd_Cmd(0x28);          /* 4-bit, 2 lines, 5x8 */
    Lcd_Cmd(0x0C);          /* Display ON, Cursor OFF */
    Lcd_Cmd(0x06);          /* Increment cursor */
    Lcd_Cmd(0x01);          /* Clear display */
    __delay_ms(2);
}


/* Faster int print - skips leading zeros */
void Lcd_Out_Int(s16 val) {
    char buf[7];
    u8 i = 0;
    u8 neg = 0;

    if (val < 0) { neg = 1; val = -val; }
    if (val == 0) { Lcd_Chr('0'); return; }

    while (val > 0) {
        buf[i++] = (val % 10) + '0';
        val /= 10;
    }
    if (neg) buf[i++] = '-';

    /* Print in reverse (correct order) */
    while (i > 0)
        Lcd_Chr(buf[--i]);
}