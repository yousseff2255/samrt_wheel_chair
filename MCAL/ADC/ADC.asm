
_ADC_Init:

;ADC.c,8 :: 		void ADC_Init(void) {
;ADC.c,11 :: 		TRISA |= 0x01;
	BSF        133, 0
;ADC.c,15 :: 		SET_BIT(ADCON1, ADCON1_ADFM);
	BSF        159, 7
;ADC.c,18 :: 		}
L_ADC_Init1:
;ADC.c,19 :: 		ADCON1 &= 0xF0;
	MOVLW      240
	ANDWF      159, 1
;ADC.c,22 :: 		ADCON0 = (ADC_CLOCK_SELECT << 6);
	MOVLW      128
	MOVWF      31
;ADC.c,23 :: 		SET_BIT(ADCON0, ADCON0_ADON);
	BSF        31, 0
;ADC.c,24 :: 		}
L_end_ADC_Init:
	RETURN
; end of _ADC_Init

_ADC_GetChannelValue:

;ADC.c,26 :: 		u16 ADC_GetChannelValue(u8 Copy_u8Channel) {
;ADC.c,27 :: 		u16 Local_u16Result = 0;
	CLRF       ADC_GetChannelValue_Local_u16Result_L0+0
;ADC.c,32 :: 		ADCON0 &= 0xC7;
	MOVLW      199
	ANDWF      31, 1
;ADC.c,34 :: 		ADCON0 |= (Copy_u8Channel << 3);
	MOVF       FARG_ADC_GetChannelValue_Copy_u8Channel+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      31, 1
;ADC.c,38 :: 		for(Local_u8Delay = 0; Local_u8Delay < 30; Local_u8Delay++) {
	CLRF       R2+0
L_ADC_GetChannelValue2:
	MOVLW      30
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_ADC_GetChannelValue3
	INCF       R2+0, 0
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R2+0
;ADC.c,40 :: 		}
	GOTO       L_ADC_GetChannelValue2
L_ADC_GetChannelValue3:
;ADC.c,43 :: 		SET_BIT(ADCON0, ADCON0_GO_DONE);
	BSF        31, 2
;ADC.c,47 :: 		while (GET_BIT(ADCON0, ADCON0_GO_DONE) == 1);
L_ADC_GetChannelValue5:
	MOVF       31, 0
	MOVWF      R0+0
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	MOVLW      1
	ANDWF      R0+0, 0
	MOVWF      R1+0
	MOVF       R1+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_ADC_GetChannelValue6
	GOTO       L_ADC_GetChannelValue5
L_ADC_GetChannelValue6:
;ADC.c,52 :: 		Local_u16Result = ((u16)ADRESH << 8) | ADRESL;
	MOVF       158, 0
	MOVWF      ADC_GetChannelValue_Local_u16Result_L0+0
;ADC.c,55 :: 		}
L_ADC_GetChannelValue8:
;ADC.c,57 :: 		return Local_u16Result;
	MOVF       ADC_GetChannelValue_Local_u16Result_L0+0, 0
	MOVWF      R0+0
;ADC.c,58 :: 		}
L_end_ADC_GetChannelValue:
	RETURN
; end of _ADC_GetChannelValue
