	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start
	
	org	0x100	; Main code starts here at address 0x100
delay250:
	movlw 0xAA
	movwf 0xAA
	movlw 0xAA
	movwf 0xAA
	return

start: 
	movlw 0xFC
	movwf TRISD, A
	movlw 0xFF
	movwf PORTD, A
	clrf TRISE
	; put data in bus LATE
	movlw 0x55
	movwf LATE
	; lower cp for 250ns
	movlw 0xFE
	movwf PORTD, A
	
	call delay250
	
	setf TRISE
	
	end	main



