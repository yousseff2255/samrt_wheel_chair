#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

#include "MOTOR_interface.h"
#include "MOTOR_config.h"

void MOTOR_Init(void) {
    /* Set RD0, RD1, RD2, RD3 as Outputs */
    MOTOR_PORT_DIR &= 0xF0; // 0b11110000 -> Bits 0,1,2,3 are outputs
    MOTOR_Stop();
}

void MOTOR_Forward(void) {
    /* Left Motor Forward, Right Motor Forward */
    SET_BIT(MOTOR_PORT, MOTOR_IN1_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN2_PIN);
    SET_BIT(MOTOR_PORT, MOTOR_IN3_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Backward(void) {
    /* Left Motor Backward, Right Motor Backward */
    CLR_BIT(MOTOR_PORT, MOTOR_IN1_PIN);
    SET_BIT(MOTOR_PORT, MOTOR_IN2_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN3_PIN);
    SET_BIT(MOTOR_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Right(void) {
    /* Left Motor Forward, Right Motor Backward -> Sharp Right Turn */
    SET_BIT(MOTOR_PORT, MOTOR_IN1_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN2_PIN);

    CLR_BIT(MOTOR_PORT, MOTOR_IN3_PIN);
    SET_BIT(MOTOR_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Left(void) {
    /* Left Motor Backward, Right Motor Forward -> Sharp Left Turn */
    CLR_BIT(MOTOR_PORT, MOTOR_IN1_PIN);
    SET_BIT(MOTOR_PORT, MOTOR_IN2_PIN);

    SET_BIT(MOTOR_PORT, MOTOR_IN3_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Stop(void) {
    /* All Stop */
    CLR_BIT(MOTOR_PORT, MOTOR_IN1_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN2_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN3_PIN);
    CLR_BIT(MOTOR_PORT, MOTOR_IN4_PIN);
}