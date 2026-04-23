#include "../../SERVICES/STD_TYPES.h"
#include "../../SERVICES/BIT_MATH.h"

#include "MOTOR_interface.h"
#include "MOTOR_private.h"
#include "MOTOR_config.h"

void MOTOR_Init(void) {
    /* Set IN1, IN2, IN3, IN4 as outputs */
    CLR_BIT(MOTOR_LEFT_DIR_PORT,  MOTOR_IN1_PIN);
    CLR_BIT(MOTOR_LEFT_DIR_PORT,  MOTOR_IN2_PIN);
    CLR_BIT(MOTOR_RIGHT_DIR_PORT, MOTOR_IN3_PIN);
    CLR_BIT(MOTOR_RIGHT_DIR_PORT, MOTOR_IN4_PIN);

    /* Start stopped */
    MOTOR_Stop();
}

void MOTOR_Forward(void) {
    /* Left Motor Forward */
    SET_BIT(MOTOR_LEFT_PORT,  MOTOR_IN1_PIN);
    CLR_BIT(MOTOR_LEFT_PORT,  MOTOR_IN2_PIN);

    /* Right Motor Forward */
    SET_BIT(MOTOR_RIGHT_PORT, MOTOR_IN3_PIN);
    CLR_BIT(MOTOR_RIGHT_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Backward(void) {
    /* Left Motor Backward */
    CLR_BIT(MOTOR_LEFT_PORT,  MOTOR_IN1_PIN);
    SET_BIT(MOTOR_LEFT_PORT,  MOTOR_IN2_PIN);

    /* Right Motor Backward */
    CLR_BIT(MOTOR_RIGHT_PORT, MOTOR_IN3_PIN);
    SET_BIT(MOTOR_RIGHT_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Left(void) {
    /* Left Motor Backward, Right Motor Forward → turn left */
    CLR_BIT(MOTOR_LEFT_PORT,  MOTOR_IN1_PIN);
    SET_BIT(MOTOR_LEFT_PORT,  MOTOR_IN2_PIN);

    SET_BIT(MOTOR_RIGHT_PORT, MOTOR_IN3_PIN);
    CLR_BIT(MOTOR_RIGHT_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Right(void) {
    /* Left Motor Forward, Right Motor Backward → turn right */
    SET_BIT(MOTOR_LEFT_PORT,  MOTOR_IN1_PIN);
    CLR_BIT(MOTOR_LEFT_PORT,  MOTOR_IN2_PIN);

    CLR_BIT(MOTOR_RIGHT_PORT, MOTOR_IN3_PIN);
    SET_BIT(MOTOR_RIGHT_PORT, MOTOR_IN4_PIN);
}

void MOTOR_Stop(void) {
    CLR_BIT(MOTOR_LEFT_PORT,  MOTOR_IN1_PIN);
    CLR_BIT(MOTOR_LEFT_PORT,  MOTOR_IN2_PIN);
    CLR_BIT(MOTOR_RIGHT_PORT, MOTOR_IN3_PIN);
    CLR_BIT(MOTOR_RIGHT_PORT, MOTOR_IN4_PIN);
}