#include <xc.inc>

global  Stepper_Setup, Stepper_CW_Big, Stepper_ACW_Big, PolarisationAngle, Stepper_delay_ms
    

psect	      udata_acs  ; named variables in access ram
Stepper_cnt_l:	ds 1	; reserve 1 byte for variable LCD_cnt_l
Stepper_cnt_h:	ds 1	; reserve 1 byte for variable LCD_cnt_h
Stepper_cnt_ms:	ds 1	; reserve 1 byte for ms counter
Stepper_tmp:	ds 1	; reserve 1 byte for temporary use
Stepper_counter:	ds 1	; reserve 1 byte for counting through nessage
PolarisationAngle:	ds 1



psect	stepper_code, class=CODE
Stepper_Setup:
    ; set PORTD to output
    movlw 0x40
    movwf TRISE, A
    movlw 0b00000010
    movwf PORTE, A
;    movlw 0x65
    movlw 0xC9
    movwf PolarisationAngle
    return
    
Stepper_CW_Big:
    movlw 0b00000011
    movwf PORTE, A
    movlw	0x10		; wait 2ms
    call	Stepper_delay_ms
    movlw 0b00000010
    movwf PORTE, A
    movlw	0x10		; wait 2ms
    call	Stepper_delay_ms
    return
    
Stepper_ACW_Big:
    movlw 0b00000001
    movwf PORTE, A
    movlw	0x10	; wait 2ms
    call	Stepper_delay_ms
    movlw 0b00000000
    movwf PORTE, A
    movlw	0x10		; wait 2ms
    call	Stepper_delay_ms
    return


Stepper_delay_ms:		    ; delay given in ms in W
	movwf	Stepper_cnt_ms, A
Stepperlp2:	movlw	250	    ; 1 ms delay
	call	Stepper_delay_x4us	
	decfsz	Stepper_cnt_ms, A
	bra	Stepperlp2
	return
    
Stepper_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	Stepper_cnt_l, A	; now need to multiply by 16
	swapf   Stepper_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	Stepper_cnt_l, W, A ; move low nibble to W
	movwf	Stepper_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	Stepper_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	Stepper_delay
	return

Stepper_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
Stepperlp1:	decf 	Stepper_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	Stepper_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	Stepperlp1		; carry, then loop again
	return	
    
    


