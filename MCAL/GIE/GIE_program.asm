
_GIE_voidEnable:

;GIE_program.c,9 :: 		void GIE_voidEnable(void) {
;GIE_program.c,10 :: 		SET_BIT(INTCON, GIE);
	BSF        11, 7
;GIE_program.c,11 :: 		}
L_end_GIE_voidEnable:
	RETURN
; end of _GIE_voidEnable

_GIE_voidDisable:

;GIE_program.c,13 :: 		void GIE_voidDisable(void) {
;GIE_program.c,14 :: 		CLR_BIT(INTCON, GIE);
	MOVLW      127
	ANDWF      11, 1
;GIE_program.c,15 :: 		}
L_end_GIE_voidDisable:
	RETURN
; end of _GIE_voidDisable
