#include "../SERVICES/STD_TYPES.h"
#include "../SERVICES/BIT_MATH.h"
#include "../HAL/ULTRASONIC/ULTRASONIC_interface.h"
#include "../HAL/ULTRASONIC/ULTRASONIC_config.h" // Include your config!
#include "../HAL/MOTOR/MOTOR_interface.h"
#include "../HAL/BUZZER/BUZZER_interface.h"
void main() {
    u16 current_dist = 0;

    ULTRASONIC_Init();
    MOTOR_Init();

    // Buzzer on RC2 (Pin 17)
    BUZZER_Init();

    while(1) {
        current_dist = ULTRASONIC_GetDistance();

        /* Use your defined macros from the config file */
        if (current_dist <= ULTRASONIC_STOP_DISTANCE) {
            /* DANGER: Stop and Alarm */
            MOTOR_Stop();
            BUZZER_On();
        }
        else {
            /* SAFE: Full speed ahead */
            MOTOR_Forward();
             BUZZER_Off();
        }
    }
}