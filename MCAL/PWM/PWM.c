#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"
#include "PWM_interface.h"
#include "PWM_private.h" /* Ensure your register addresses are here */

void PWM1_Init(u8 Copy_u8PR2Value) {
    // STEP 1: Set the PWM period
    PR2 = Copy_u8PR2Value;

    // STEP 2: Initial Duty Cycle (Set to 0% by default)
    CCPR1L = 0;
    CCP1CON &= 0xCF;

    // STEP 3: Make RC2/CCP1 an output
    CLR_BIT(TRISC, 2);

    // STEP 4: Set Prescaler to 16 and turn on Timer2
    T2CON = 0x07;

    // STEP 5: Configure CCP1 for PWM mode
    CCP1CON |= 0x0C;
}

void PWM1_SetDutyCycle(u8 duty_percentage) {
    u16 duty_value;
    if (duty_percentage > 100) duty_percentage = 100;

    /* Resolution is 4 * (PR2 + 1) */
    duty_value = (u16)((u32)(4 * (PR2 + 1) * duty_percentage) / 100);

    CCPR1L = (u8)(duty_value >> 2);
    CCP1CON &= 0xCF;
    CCP1CON |= ((u8)(duty_value & 0x03) << 4);
}

void PWM1_Stop(void) {
    CLR_BIT(T2CON, TMR2ON);   // Stop Timer2
    CCP1CON &= 0xF0;           // Clear PWM mode bits
    CLR_BIT(PORTC, 2);         // Drive pin low explicitly
}




///////////////////////////////////

void PWM2_Init(u8 Copy_u8PR2Value) {
    // STEP 1: Set the PWM period
    PR2 = Copy_u8PR2Value;

    // STEP 2: Initial Duty Cycle (Set to 0% by default)
    CCPR2L = 0;
    CCP2CON &= 0xCF;

    // STEP 3: Make RC2/CCP1 an output
    CLR_BIT(TRISC, 1);

    // STEP 4: Set Prescaler to 16 and turn on Timer2
    T2CON = 0x07;

    // STEP 5: Configure CCP1 for PWM mode
    CCP2CON |= 0x0C;
}

void PWM2_SetDutyCycle(u8 duty_percentage) {
    u16 duty_value;
    if (duty_percentage > 100) duty_percentage = 100;

    /* Resolution is 4 * (PR2 + 1) */
    duty_value = (u16)((u32)(4 * (PR2 + 1) * duty_percentage) / 100);

    CCPR2L = (u8)(duty_value >> 2);
    CCP2CON &= 0xCF;
    CCP2CON |= ((u8)(duty_value & 0x03) << 4);
}

void PWM2_Stop(void) {
    CLR_BIT(T2CON, TMR2ON);   // Stop Timer2
    CCP2CON &= 0xF0;           // Clear PWM mode bits
    CLR_BIT(PORTC, 1);         // Drive pin low explicitly
}