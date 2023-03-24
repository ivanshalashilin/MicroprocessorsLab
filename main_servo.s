#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message, UART_Transmit_Byte  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn   Stepper_Setup, Stepper_CW_Big, Stepper_ACW_Big, Stepper_delay_ms
extrn   GetDecimalDigits, Delay_FiveSixths, LongDelay17, Delay_17
extrn   Servo_Setup
extrn   Pulse5Times, HighCount, PolarisationAngle, LowCount
extrn   OUT3, OUT2, OUT1, OUT0
global  CWorACW, TEMPOUT3, TEMPOUT2, TEMPOUT1
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
CWorACW: ds 1
TEMPOUT3:	    ds 1
TEMPOUT2:	    ds 1
TEMPOUT1:	    ds 1

    
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
	

;	movlw  0x30
;	call UART_Transmit_Byte
;	movlw 0x0A
;	call UART_Transmit_Byte

	
	call	ADC_Setup
	call	Stepper_Setup
	movlw	0x00
	movwf	CWorACW
	;multiply debud
	call    Servo_Setup

ChangeAltitude:
	;call	Pulse5Times
	;call	Delay_17
	;call	LongDelay17
	;call	LongDelay17
;	movlw   0x0a ;"\n"
	
;	call    UART_Transmit_Byte
	
	;tstfsz	CWorACW
	;goto    TransmitAndRotate180CW	
	goto	Transmit1Step
ChangeAltitudeAfter1Step:
;	incf HighCount
;	movlw 0x40
;	cpfseq HighCount
	decfsz	HighCount
	bra  ChangeAltitude
	bra  setup
	
Transmit1Step:
	
	
	;call Delay_17
	
	call FindConvergedSignal

	
	movlw   0x30
	addwf   OUT3, 0
	call    UART_Transmit_Byte
	
	movlw   0x30
	addwf   OUT2, 0
	call    UART_Transmit_Byte  
	
	movlw   0x30
	addwf   OUT1, 0
	call    UART_Transmit_Byte  
	
	movlw   0x30
	addwf   OUT0, 0
	call    UART_Transmit_Byte  
	
	
	movlw   0x0a ;"\n"
	call    UART_Transmit_Byte
	
	movlw   0x05
	movwf   delay_count
	call    delay
	
	goto     ChangeAltitudeAfter1Step

	
FindConvergedSignal:
    ;get initial intensity and store
	call	ADC_Read
	call    GetDecimalDigits
	movff OUT3, TEMPOUT3
	movff OUT2, TEMPOUT2
	movff OUT1, TEMPOUT1
    ;pause
	call Delay_17
    ;get second intensity and compare
	call	ADC_Read
	call    GetDecimalDigits
	movff OUT3, WREG
	cpfseq TEMPOUT3
	bra FindConvergedSignal
	movff OUT2, WREG
	cpfseq TEMPOUT2
	bra FindConvergedSignal
	movff OUT1, WREG
	cpfseq TEMPOUT1
	bra FindConvergedSignal
	return 
	
	
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst