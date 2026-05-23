/* =============================================================
 * FINAL TEST: ULTRASONIC + MPU6050 + MAX30102 + LCD + UART + MOTOR + BUZZER
 * PIC16F877A @ 10 MHz HS oscillator
 * ============================================================= */
#pragma config FOSC = HS
#pragma config WDTE = OFF
#pragma config PWRTE = ON
#pragma config BOREN = ON
#pragma config LVP  = OFF
#pragma config CPD  = OFF
#pragma config WRT  = OFF
#pragma config CP   = OFF

#include <xc.h>
#include <stdint.h>

#define _XTAL_FREQ 10000000UL

#include "../SERVICES/STD_TYPES.h"
#include "../MCAL/I2C/I2C_interface.h"
#include "../MCAL/UART/UART_interface.h"
#include "../HAL/ULTRASONIC/ULTRASONIC_interface.h"
#include "../HAL/MPU6050/MPU6050_interface.h"
#include "../HAL/MAX30102/MAX30102_interface.h"
#include "../HAL/MOTOR/MOTOR_interface.h"
#include "../HAL/BUZZER/BUZZER_interface.h"

/* Thresholds */
#define DIST_WARNING_THRESH  50
#define DIST_STOP_THRESH     20

/* Pi Command Buffer */
static volatile uint8_t g_pi_command = 'F'; /* CHANGED: Default to Forward, don't wait for Pi */
static volatile uint8_t g_cmd_ready  = 0;

/* ---------------------------------------------------------------
 * Timer0: 1ms tick
 * --------------------------------------------------------------- */
volatile u32 g_systemTick_ms = 0;

void Timer0_Init(void) {
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.PSA  = 0;
    OPTION_REGbits.PS   = 0b011; /* 1:16 prescaler -> ~1ms @ 10MHz */
    TMR0   = 100;
    TMR0IE = 1;
    TMR0IF = 0;
}

/* ---------------------------------------------------------------
 * UART RX Interrupt (RCIF) + Timer0 ISR
 * --------------------------------------------------------------- */
void __interrupt() ISR(void) {
    /* Timer0 -> system tick */
    if (TMR0IF) {
        g_systemTick_ms++;
        TMR0  = 100;
        TMR0IF = 0;
    }

    /* UART RX -> capture Pi command */
    if (PIR1bits.RCIF) {
        uint8_t rx = RCREG;          /* Reading RCREG clears RCIF */

        /* Accept only valid command bytes; ignore noise */
        if (rx == 'F' || rx == 'S' || rx == 'B' || rx == 'L' || rx == 'R') {
            g_pi_command = rx;
            g_cmd_ready  = 1;
        }

        /* Clear any framing/overrun errors so UART doesn't freeze */
        if (RCSTAbits.OERR) {
            RCSTAbits.CREN = 0;
            RCSTAbits.CREN = 1;
        }
    }
}

/* ---------------------------------------------------------------
 * LCD (I2C PCF8574 backpack)
 * --------------------------------------------------------------- */
#define LCD_ADDR 0x4E
#define LCD_EN   0x04
#define LCD_RS   0x01
#define LCD_BL   0x08

static void Lcd_Write_Nibble(uint8_t nibble, uint8_t rs) {
    uint8_t data = nibble | rs | LCD_BL;
    I2C_Start();
    I2C_Write(LCD_ADDR);
    I2C_Write(data | LCD_EN);  __delay_us(5);
    I2C_Write(data & ~LCD_EN);
    I2C_Stop();
    __delay_us(50);
}

static void Lcd_Cmd(uint8_t cmd) {
    Lcd_Write_Nibble(cmd & 0xF0, 0);
    Lcd_Write_Nibble((cmd << 4) & 0xF0, 0);
    if (cmd == 0x01 || cmd == 0x02) __delay_ms(2);
}

static void Lcd_Char(char c) {
    Lcd_Write_Nibble(c  & 0xF0, LCD_RS);
    Lcd_Write_Nibble((c << 4) & 0xF0, LCD_RS);
}

static void Lcd_String(const char *str) { while (*str) Lcd_Char(*str++); }

static void Lcd_Out_Int(int16_t num) {
    char buf[7]; uint8_t i = 0; uint8_t neg = 0;
    if (num < 0) { neg = 1; num = -num; }
    if (num == 0) { Lcd_Char('0'); return; }
    while (num > 0) { buf[i++] = (num % 10) + '0'; num /= 10; }
    if (neg) Lcd_Char('-');
    while (i > 0) Lcd_Char(buf[--i]);
}

static void Lcd_Init_Raw(void) {
    __delay_ms(50);
    Lcd_Write_Nibble(0x30, 0); __delay_ms(5);
    Lcd_Write_Nibble(0x30, 0); __delay_us(150);
    Lcd_Write_Nibble(0x30, 0); __delay_us(150);
    Lcd_Write_Nibble(0x20, 0); __delay_ms(2);
    Lcd_Cmd(0x28); Lcd_Cmd(0x0C); Lcd_Cmd(0x06); Lcd_Cmd(0x01);
    __delay_ms(2);
}

/* ---------------------------------------------------------------
 * Send structured packet to Raspberry Pi
 * Format: $WC,<dist>,<bpm>,<spo2>,<tiltX>,<tiltY>,<finger>,<fall>,<collision>,<moving>\r\n
 * --------------------------------------------------------------- */
static void Send_Pi_Packet(uint16_t dist,
                           MAX30102_Result_t *v,
                           MPU6050_Tilt     *t,
                           uint8_t           fall,
                           uint8_t           collision,
                           uint8_t           moving)
{
    UART_SendString("$WC,");
    UART_SendNum(dist);       UART_SendString(",");
    UART_SendNum(v->bpm);     UART_SendString(",");
    UART_SendNum(v->spo2);    UART_SendString(",");
    UART_SendNum(t->x);       UART_SendString(",");
    UART_SendNum(t->y);       UART_SendString(",");
    UART_SendNum(v->fingerDetected); UART_SendString(",");
    UART_SendNum(fall);       UART_SendString(",");
    UART_SendNum(collision);  UART_SendString(",");
    UART_SendNum(moving);     UART_SendString("\r\n");
}

/* ---------------------------------------------------------------
 * MAIN
 * --------------------------------------------------------------- */
void main(void) {
    uint16_t        dist       = 0;
    MPU6050_Tilt    tilt_data;
    MAX30102_Result_t vitals_data;

    uint8_t fall_flag      = 0;
    uint8_t collision_flag = 0;
    uint8_t is_moving      = 1; /* CHANGED: Starts as moving by default */

    /* Status LEDs */
    TRISBbits.TRISB1 = 0; PORTBbits.RB1 = 0;  /* Heartbeat */
    TRISBbits.TRISB2 = 0; PORTBbits.RB2 = 0;  /* Obstacle/Fall warning */

    /* Global + Peripheral interrupts ON */
    INTCONbits.GIE  = 1;
    INTCONbits.PEIE = 1;

    /* Peripherals */
    I2C_Init(100000);
    UART_Init(9600);

    /* Enable UART RX interrupt */
    PIE1bits.RCIE = 1;

    Timer0_Init();
    Lcd_Init_Raw();
    ULTRASONIC_Init();
    MOTOR_Init();
    BUZZER_Init();

    /* Sensor boot */
    UART_SendString("\r\n[BOOT] Initializing...\r\n");

    if (MAX30102_Init() == MAX30102_OK)
        UART_SendString("[BOOT] MAX30102 OK.\r\n");
    else
        UART_SendString("[BOOT] MAX30102 FAILED!\r\n");

    MPU6050_Init();

    Lcd_Cmd(0x80);
    Lcd_String("Keep Chair Flat!");
    UART_SendString("[BOOT] Calibrating MPU...\r\n");
    __delay_ms(2000);

    MPU6050_Calibrate();
    UART_SendString("[BOOT] System Ready.\r\n");
    Lcd_Cmd(0x01);

    MOTOR_Forward(); /* CHANGED: Drive forward automatically after boot calibration */

    /* --------------------------------------------------------
     * MAIN LOOP
     * -------------------------------------------------------- */
    while (1) {
        PORTBbits.RB1 ^= 1;   /* Heartbeat LED */

        /* 1. Read sensors */
        dist = ULTRASONIC_GetDistance();
        MPU6050_Update();
        MAX30102_Update();

        MPU6050_GetTilt(&tilt_data);
        MAX30102_GetResult(&vitals_data);

        /* 2. Evaluate safety flags */
        fall_flag      = MPU6050_IsFalling() ? 1 : 0;
        collision_flag = (dist <= DIST_STOP_THRESH) ? 1 : 0;

        /* 3. Safety-first actuator logic */
        if (fall_flag) {
            /* Ultimate Safety: If the chair falls over, completely freeze everything */
            MOTOR_Stop();
            BUZZER_On();
            PORTBbits.RB2 = 1;
            is_moving = 0;

        } else if (dist <= DIST_STOP_THRESH) {
            /* CRITICAL CLOSE RANGE: Danger zone! */
            BUZZER_On();         /* Keep buzzer on to alert user */
            PORTBbits.RB2 = 1;   /* Keep warning LED on */

            /* BLOCK Forward, but ALLOW escape maneuvers (Backward, Left, Right) */
            if (g_pi_command == 'B') {
                MOTOR_Backward();
                is_moving = 1;
            } else if (g_pi_command == 'L') {
                MOTOR_Left();
                is_moving = 1;
            } else if (g_pi_command == 'R') {
                MOTOR_Right();
                is_moving = 1;
            } else {
                /* If command is 'F' (Forward) or 'S' (Stop), force stop to prevent crash */
                MOTOR_Stop();
                is_moving = 0;
            }

        } else if (dist <= DIST_WARNING_THRESH) {
            /* WARNING RANGE: Obstacle approaching ahead */
            BUZZER_On();
            PORTBbits.RB2 = 1;

            /* Allow escaping or re-orienting here as well */
            if (g_pi_command == 'B') {
                MOTOR_Backward();
                is_moving = 1;
            } else if (g_pi_command == 'L') {
                MOTOR_Left();
                is_moving = 1;
            } else if (g_pi_command == 'R') {
                MOTOR_Right();
                is_moving = 1;
            } else {
                /* Forward allowed? Since it's just a warning, we can still block forward or allow it.
                   Based on your previous setup, we blocked forward here to prevent getting closer. */
                MOTOR_Stop();
                is_moving = 0;
            }

        } else {
            /* CLEAR PATH: Normal operation, obey Pi fully */
            BUZZER_Off();
            PORTBbits.RB2 = 0;

            switch (g_pi_command) {
                case 'F': MOTOR_Forward();  is_moving = 1; break;
                case 'B': MOTOR_Backward(); is_moving = 1; break;
                case 'L': MOTOR_Left();     is_moving = 1; break;
                case 'R': MOTOR_Right();    is_moving = 1; break;
                case 'S':
                default:  MOTOR_Stop();     is_moving = 0; break;
            }
        }

        /* 4. Send structured packet to Pi every 200ms (5Hz) */
        static uint32_t last_tx_time = 0;
        if ((g_systemTick_ms - last_tx_time) >= 200) {
            last_tx_time = g_systemTick_ms;
            
            Send_Pi_Packet(dist, &vitals_data, &tilt_data,
                           fall_flag, collision_flag, is_moving);
        }

        /* 5. LCD update every 500ms */
        static uint32_t last_lcd_time = 0;
        if ((g_systemTick_ms - last_lcd_time) >= 500) {
            last_lcd_time = g_systemTick_ms;

            Lcd_Cmd(0x80);
            Lcd_String("D:");
            Lcd_Out_Int(dist);
            Lcd_String(" B:");
            if (vitals_data.fingerDetected)
                Lcd_Out_Int(vitals_data.bpm);
            else
                Lcd_String("--");
            Lcd_String("   ");

            Lcd_Cmd(0xC0);
            if (fall_flag) {
                Lcd_String("*FALL DETECTED* ");
            } else if (MPU6050_IsWarning()) {
                Lcd_String("*TILT WARNING* ");
            } else {
                Lcd_String("X:");
                Lcd_Out_Int(tilt_data.x);
                Lcd_String(" Y:");
                Lcd_Out_Int(tilt_data.y);
                Lcd_String("     ");
            }
        }

        __delay_ms(10);
    }
}