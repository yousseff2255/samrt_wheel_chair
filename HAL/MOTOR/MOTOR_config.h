#ifndef MOTOR_CONFIG_H
#define MOTOR_CONFIG_H

/* Left Motor — IN1, IN2 on PORTD */
#define MOTOR_LEFT_DIR_PORT     TRISD
#define MOTOR_LEFT_PORT         PORTD
#define MOTOR_IN1_PIN           0   /* RD0 */
#define MOTOR_IN2_PIN           1   /* RD1 */

/* Right Motor — IN3, IN4 on PORTD */
#define MOTOR_RIGHT_DIR_PORT    TRISD
#define MOTOR_RIGHT_PORT        PORTD
#define MOTOR_IN3_PIN           2   /* RD2 */
#define MOTOR_IN4_PIN           3   /* RD3 */

#endif