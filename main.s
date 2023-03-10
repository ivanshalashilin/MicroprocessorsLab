#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message, UART_Transmit_Byte  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn   Stepper_Setup, Stepper_CW_Big, Stepper_ACW_Big
	
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
;	 ******* myTable, data in programme memory, and its length *****
myTable:
	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
					; message, plus carriage return
	myTable_l   EQU	13	; length of data
	align	2
;    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	ADC_Setup
	call	Stepper_Setup
	goto	collect_data
	
collect_data:
	call	ADC_Read
	movlw   0x30
	addwf	ADRESH, 0
	;movf	ADRESH, W, A
	call	UART_Transmit_Byte
;	call	LCD_Write_Hex
	movlw	0x30
	addwf	ADRESL, 0
	;movf	ADRESL, W, A
	call	UART_Transmit_Byte	
	call    Stepper_CW_Big
	movlw   0x0F
	movwf   delay_count
	call    delay 
	goto    collect_data 
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst