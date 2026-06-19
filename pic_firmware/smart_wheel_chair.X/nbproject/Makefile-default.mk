#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=gnumkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=elf
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=-mafrlcsj
else
COMPARISON_BUILD=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=../APP/test.c ../HAL/BUZZER/BUZZER.c ../HAL/LED/LED.c ../HAL/MAX30102/MAX30102_program.c ../HAL/MOTOR/MOTOR.c ../HAL/MPU6050/MPU6050.c ../HAL/ULTRASONIC/ULTRASONIC.c ../MCAL/EXTI/EXTI.c ../MCAL/GIE/GIE_program.c ../MCAL/GPIO/GPIO.c ../MCAL/I2C/I2C.c ../MCAL/UART/UART.c

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/_ext/1360888114/test.p1 ${OBJECTDIR}/_ext/267267701/BUZZER.p1 ${OBJECTDIR}/_ext/272192768/LED.p1 ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1 ${OBJECTDIR}/_ext/416994346/MOTOR.p1 ${OBJECTDIR}/_ext/1328384892/MPU6050.p1 ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1 ${OBJECTDIR}/_ext/1210050073/EXTI.p1 ${OBJECTDIR}/_ext/1762082884/GIE_program.p1 ${OBJECTDIR}/_ext/1209998514/GPIO.p1 ${OBJECTDIR}/_ext/1762084091/I2C.p1 ${OBJECTDIR}/_ext/1209595571/UART.p1
POSSIBLE_DEPFILES=${OBJECTDIR}/_ext/1360888114/test.p1.d ${OBJECTDIR}/_ext/267267701/BUZZER.p1.d ${OBJECTDIR}/_ext/272192768/LED.p1.d ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1.d ${OBJECTDIR}/_ext/416994346/MOTOR.p1.d ${OBJECTDIR}/_ext/1328384892/MPU6050.p1.d ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1.d ${OBJECTDIR}/_ext/1210050073/EXTI.p1.d ${OBJECTDIR}/_ext/1762082884/GIE_program.p1.d ${OBJECTDIR}/_ext/1209998514/GPIO.p1.d ${OBJECTDIR}/_ext/1762084091/I2C.p1.d ${OBJECTDIR}/_ext/1209595571/UART.p1.d

# Object Files
OBJECTFILES=${OBJECTDIR}/_ext/1360888114/test.p1 ${OBJECTDIR}/_ext/267267701/BUZZER.p1 ${OBJECTDIR}/_ext/272192768/LED.p1 ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1 ${OBJECTDIR}/_ext/416994346/MOTOR.p1 ${OBJECTDIR}/_ext/1328384892/MPU6050.p1 ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1 ${OBJECTDIR}/_ext/1210050073/EXTI.p1 ${OBJECTDIR}/_ext/1762082884/GIE_program.p1 ${OBJECTDIR}/_ext/1209998514/GPIO.p1 ${OBJECTDIR}/_ext/1762084091/I2C.p1 ${OBJECTDIR}/_ext/1209595571/UART.p1

# Source Files
SOURCEFILES=../APP/test.c ../HAL/BUZZER/BUZZER.c ../HAL/LED/LED.c ../HAL/MAX30102/MAX30102_program.c ../HAL/MOTOR/MOTOR.c ../HAL/MPU6050/MPU6050.c ../HAL/ULTRASONIC/ULTRASONIC.c ../MCAL/EXTI/EXTI.c ../MCAL/GIE/GIE_program.c ../MCAL/GPIO/GPIO.c ../MCAL/I2C/I2C.c ../MCAL/UART/UART.c



CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk ${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=16F877A
# ------------------------------------------------------------------------------------
# Rules for buildStep: compile
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/_ext/1360888114/test.p1: ../APP/test.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1360888114" 
	@${RM} ${OBJECTDIR}/_ext/1360888114/test.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1360888114/test.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1360888114/test.p1 ../APP/test.c 
	@-${MV} ${OBJECTDIR}/_ext/1360888114/test.d ${OBJECTDIR}/_ext/1360888114/test.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1360888114/test.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/267267701/BUZZER.p1: ../HAL/BUZZER/BUZZER.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/267267701" 
	@${RM} ${OBJECTDIR}/_ext/267267701/BUZZER.p1.d 
	@${RM} ${OBJECTDIR}/_ext/267267701/BUZZER.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/267267701/BUZZER.p1 ../HAL/BUZZER/BUZZER.c 
	@-${MV} ${OBJECTDIR}/_ext/267267701/BUZZER.d ${OBJECTDIR}/_ext/267267701/BUZZER.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/267267701/BUZZER.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/272192768/LED.p1: ../HAL/LED/LED.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/272192768" 
	@${RM} ${OBJECTDIR}/_ext/272192768/LED.p1.d 
	@${RM} ${OBJECTDIR}/_ext/272192768/LED.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/272192768/LED.p1 ../HAL/LED/LED.c 
	@-${MV} ${OBJECTDIR}/_ext/272192768/LED.d ${OBJECTDIR}/_ext/272192768/LED.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/272192768/LED.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1: ../HAL/MAX30102/MAX30102_program.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/2114281539" 
	@${RM} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1.d 
	@${RM} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1 ../HAL/MAX30102/MAX30102_program.c 
	@-${MV} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.d ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/416994346/MOTOR.p1: ../HAL/MOTOR/MOTOR.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/416994346" 
	@${RM} ${OBJECTDIR}/_ext/416994346/MOTOR.p1.d 
	@${RM} ${OBJECTDIR}/_ext/416994346/MOTOR.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/416994346/MOTOR.p1 ../HAL/MOTOR/MOTOR.c 
	@-${MV} ${OBJECTDIR}/_ext/416994346/MOTOR.d ${OBJECTDIR}/_ext/416994346/MOTOR.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/416994346/MOTOR.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1328384892/MPU6050.p1: ../HAL/MPU6050/MPU6050.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1328384892" 
	@${RM} ${OBJECTDIR}/_ext/1328384892/MPU6050.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1328384892/MPU6050.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1328384892/MPU6050.p1 ../HAL/MPU6050/MPU6050.c 
	@-${MV} ${OBJECTDIR}/_ext/1328384892/MPU6050.d ${OBJECTDIR}/_ext/1328384892/MPU6050.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1328384892/MPU6050.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1: ../HAL/ULTRASONIC/ULTRASONIC.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/698714293" 
	@${RM} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1.d 
	@${RM} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1 ../HAL/ULTRASONIC/ULTRASONIC.c 
	@-${MV} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.d ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1210050073/EXTI.p1: ../MCAL/EXTI/EXTI.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1210050073" 
	@${RM} ${OBJECTDIR}/_ext/1210050073/EXTI.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1210050073/EXTI.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1210050073/EXTI.p1 ../MCAL/EXTI/EXTI.c 
	@-${MV} ${OBJECTDIR}/_ext/1210050073/EXTI.d ${OBJECTDIR}/_ext/1210050073/EXTI.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1210050073/EXTI.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1762082884/GIE_program.p1: ../MCAL/GIE/GIE_program.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1762082884" 
	@${RM} ${OBJECTDIR}/_ext/1762082884/GIE_program.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1762082884/GIE_program.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1762082884/GIE_program.p1 ../MCAL/GIE/GIE_program.c 
	@-${MV} ${OBJECTDIR}/_ext/1762082884/GIE_program.d ${OBJECTDIR}/_ext/1762082884/GIE_program.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1762082884/GIE_program.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1209998514/GPIO.p1: ../MCAL/GPIO/GPIO.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1209998514" 
	@${RM} ${OBJECTDIR}/_ext/1209998514/GPIO.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1209998514/GPIO.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1209998514/GPIO.p1 ../MCAL/GPIO/GPIO.c 
	@-${MV} ${OBJECTDIR}/_ext/1209998514/GPIO.d ${OBJECTDIR}/_ext/1209998514/GPIO.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1209998514/GPIO.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1762084091/I2C.p1: ../MCAL/I2C/I2C.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1762084091" 
	@${RM} ${OBJECTDIR}/_ext/1762084091/I2C.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1762084091/I2C.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1762084091/I2C.p1 ../MCAL/I2C/I2C.c 
	@-${MV} ${OBJECTDIR}/_ext/1762084091/I2C.d ${OBJECTDIR}/_ext/1762084091/I2C.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1762084091/I2C.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1209595571/UART.p1: ../MCAL/UART/UART.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1209595571" 
	@${RM} ${OBJECTDIR}/_ext/1209595571/UART.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1209595571/UART.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c  -D__DEBUG=1  -mdebugger=none   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1209595571/UART.p1 ../MCAL/UART/UART.c 
	@-${MV} ${OBJECTDIR}/_ext/1209595571/UART.d ${OBJECTDIR}/_ext/1209595571/UART.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1209595571/UART.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
else
${OBJECTDIR}/_ext/1360888114/test.p1: ../APP/test.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1360888114" 
	@${RM} ${OBJECTDIR}/_ext/1360888114/test.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1360888114/test.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1360888114/test.p1 ../APP/test.c 
	@-${MV} ${OBJECTDIR}/_ext/1360888114/test.d ${OBJECTDIR}/_ext/1360888114/test.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1360888114/test.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/267267701/BUZZER.p1: ../HAL/BUZZER/BUZZER.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/267267701" 
	@${RM} ${OBJECTDIR}/_ext/267267701/BUZZER.p1.d 
	@${RM} ${OBJECTDIR}/_ext/267267701/BUZZER.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/267267701/BUZZER.p1 ../HAL/BUZZER/BUZZER.c 
	@-${MV} ${OBJECTDIR}/_ext/267267701/BUZZER.d ${OBJECTDIR}/_ext/267267701/BUZZER.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/267267701/BUZZER.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/272192768/LED.p1: ../HAL/LED/LED.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/272192768" 
	@${RM} ${OBJECTDIR}/_ext/272192768/LED.p1.d 
	@${RM} ${OBJECTDIR}/_ext/272192768/LED.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/272192768/LED.p1 ../HAL/LED/LED.c 
	@-${MV} ${OBJECTDIR}/_ext/272192768/LED.d ${OBJECTDIR}/_ext/272192768/LED.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/272192768/LED.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1: ../HAL/MAX30102/MAX30102_program.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/2114281539" 
	@${RM} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1.d 
	@${RM} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1 ../HAL/MAX30102/MAX30102_program.c 
	@-${MV} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.d ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/2114281539/MAX30102_program.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/416994346/MOTOR.p1: ../HAL/MOTOR/MOTOR.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/416994346" 
	@${RM} ${OBJECTDIR}/_ext/416994346/MOTOR.p1.d 
	@${RM} ${OBJECTDIR}/_ext/416994346/MOTOR.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/416994346/MOTOR.p1 ../HAL/MOTOR/MOTOR.c 
	@-${MV} ${OBJECTDIR}/_ext/416994346/MOTOR.d ${OBJECTDIR}/_ext/416994346/MOTOR.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/416994346/MOTOR.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1328384892/MPU6050.p1: ../HAL/MPU6050/MPU6050.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1328384892" 
	@${RM} ${OBJECTDIR}/_ext/1328384892/MPU6050.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1328384892/MPU6050.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1328384892/MPU6050.p1 ../HAL/MPU6050/MPU6050.c 
	@-${MV} ${OBJECTDIR}/_ext/1328384892/MPU6050.d ${OBJECTDIR}/_ext/1328384892/MPU6050.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1328384892/MPU6050.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1: ../HAL/ULTRASONIC/ULTRASONIC.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/698714293" 
	@${RM} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1.d 
	@${RM} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1 ../HAL/ULTRASONIC/ULTRASONIC.c 
	@-${MV} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.d ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/698714293/ULTRASONIC.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1210050073/EXTI.p1: ../MCAL/EXTI/EXTI.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1210050073" 
	@${RM} ${OBJECTDIR}/_ext/1210050073/EXTI.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1210050073/EXTI.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1210050073/EXTI.p1 ../MCAL/EXTI/EXTI.c 
	@-${MV} ${OBJECTDIR}/_ext/1210050073/EXTI.d ${OBJECTDIR}/_ext/1210050073/EXTI.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1210050073/EXTI.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1762082884/GIE_program.p1: ../MCAL/GIE/GIE_program.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1762082884" 
	@${RM} ${OBJECTDIR}/_ext/1762082884/GIE_program.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1762082884/GIE_program.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1762082884/GIE_program.p1 ../MCAL/GIE/GIE_program.c 
	@-${MV} ${OBJECTDIR}/_ext/1762082884/GIE_program.d ${OBJECTDIR}/_ext/1762082884/GIE_program.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1762082884/GIE_program.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1209998514/GPIO.p1: ../MCAL/GPIO/GPIO.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1209998514" 
	@${RM} ${OBJECTDIR}/_ext/1209998514/GPIO.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1209998514/GPIO.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1209998514/GPIO.p1 ../MCAL/GPIO/GPIO.c 
	@-${MV} ${OBJECTDIR}/_ext/1209998514/GPIO.d ${OBJECTDIR}/_ext/1209998514/GPIO.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1209998514/GPIO.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1762084091/I2C.p1: ../MCAL/I2C/I2C.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1762084091" 
	@${RM} ${OBJECTDIR}/_ext/1762084091/I2C.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1762084091/I2C.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1762084091/I2C.p1 ../MCAL/I2C/I2C.c 
	@-${MV} ${OBJECTDIR}/_ext/1762084091/I2C.d ${OBJECTDIR}/_ext/1762084091/I2C.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1762084091/I2C.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
${OBJECTDIR}/_ext/1209595571/UART.p1: ../MCAL/UART/UART.c  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} "${OBJECTDIR}/_ext/1209595571" 
	@${RM} ${OBJECTDIR}/_ext/1209595571/UART.p1.d 
	@${RM} ${OBJECTDIR}/_ext/1209595571/UART.p1 
	${MP_CC} $(MP_EXTRA_CC_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -c   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -DXPRJ_default=$(CND_CONF)  -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits $(COMPARISON_BUILD)  -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     -o ${OBJECTDIR}/_ext/1209595571/UART.p1 ../MCAL/UART/UART.c 
	@-${MV} ${OBJECTDIR}/_ext/1209595571/UART.d ${OBJECTDIR}/_ext/1209595571/UART.p1.d 
	@${FIXDEPS} ${OBJECTDIR}/_ext/1209595571/UART.p1.d $(SILENT) -rsi ${MP_CC_DIR}../  
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assembleWithPreprocess
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -Wl,-Map=${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.map  -D__DEBUG=1  -mdebugger=none  -DXPRJ_default=$(CND_CONF)  -Wl,--defsym=__MPLAB_BUILD=1   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits -std=c99 -gdwarf-3 -mstack=compiled:auto:auto        $(COMPARISON_BUILD) -Wl,--memorysummary,${DISTDIR}/memoryfile.xml -o ${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
	@${RM} ${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.hex 
	
	
else
${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE) -mcpu=$(MP_PROCESSOR_OPTION) -Wl,-Map=${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.map  -DXPRJ_default=$(CND_CONF)  -Wl,--defsym=__MPLAB_BUILD=1   -mdfp="${DFP_DIR}/xc8"  -O0 -fasmfile -maddrqual=ignore -xassembler-with-cpp -mwarn=-3 -Wa,-a -msummary=-psect,-class,+mem,-hex,-file  -ginhx32 -Wl,--data-init -mno-keep-startup -mno-osccal -mno-resetbits -mno-save-resetbits -mno-download -mno-stackcall -mno-default-config-bits -std=c99 -gdwarf-3 -mstack=compiled:auto:auto     $(COMPARISON_BUILD) -Wl,--memorysummary,${DISTDIR}/memoryfile.xml -o ${DISTDIR}/smart_wheel_chair.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  ${OBJECTFILES_QUOTED_IF_SPACED}     
	
	
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${OBJECTDIR}
	${RM} -r ${DISTDIR}

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(wildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
