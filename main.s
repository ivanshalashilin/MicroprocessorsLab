#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message, UART_Transmit_Byte  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex
extrn	ADC_Setup, ADC_Read		   ; external ADC subroutines
extrn   Stepper_Setup, Stepper_CW_Big, Stepper_ACW_Big
extrn   GetDecimalDigits, Delay_FiveSixths, LongDelay17, Delay_17
extrn   Servo_Setup
extrn   Pulse5Times, HighCount, PolarisationAngle
extrn   OUT3, OUT2, OUT1, OUT0
global  CWorACW
    
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
CWorACW: ds 1
    
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
	movlw 0x00
	movwf CWorACW
	;multiply debud
	call    Servo_Setup

ChangeAltitude:
	call	Pulse5Times
	call	LongDelay17
	;movlw   0x0a ;"\n"
	;call    UART_Transmit_Byte
	tstfsz	CWorACW
	goto    TransmitAndRotate180CW
	goto	TransmitAndRotate180ACW
ChangeAltitudeAfter180:
	
	decfsz	HighCount
	bra  ChangeAltitude
	bra  setup

TransmitAndRotate180CW:
	decfsz	PolarisationAngle, A	; decrement until zero
	bra	TransmitAndRotate1StepCW
	
	
	
	movlw 0x65
	movwf PolarisationAngle
	
	movlw 0x00
	movwf CWorACW
	
	goto ChangeAltitudeAfter180
	
TransmitAndRotate180ACW:
	decfsz	PolarisationAngle, A	; decrement until zero
	bra	TransmitAndRotate1StepACW
	
	
	
	movlw 0x65
	movwf PolarisationAngle
	
	movlw 0x01
	movwf CWorACW
	
	goto ChangeAltitudeAfter180



	
TransmitAndRotate1StepCW:
	call	ADC_Read
	;movlw   0x30
	;addwf	ADRESH, 0
	;movf	ADRESH, W, A
	;send byte to be converted. digits stored in OUT3,OUT2,OUT1,OUT0
	
	call Delay_17
	
	call    GetDecimalDigits
	
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
	;movlw   0x2C ; comma
	;call    UART_Transmit_Byte
	
	
	;call	UART_Transmit_Byte
;	call	LCD_Write_Hex
	;movlw	0x30
	;addwf	ADRESL, 0
	;movf	ADRESL, W, A
	;call	UART_Transmit_Byte
	
	
	;movlw   0x0A ;"\n"
	;call    UART_Transmit_Byte
	
	
	call    Stepper_CW_Big
	movlw   0x05
	movwf   delay_count
	call    delay
	;bra TransmitAndRotate1StepCW
	goto     TransmitAndRotate180CW

TransmitAndRotate1StepACW:
	call	ADC_Read
	
	call Delay_17
	
	call    GetDecimalDigits
	
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
	
	call    Stepper_ACW_Big
	movlw   0x05
	movwf   delay_count
	call    delay
	;bra TransmitAndRotate1StepCW
	goto     TransmitAndRotate180ACW
	
	
	
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return

	end	rst