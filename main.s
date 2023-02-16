	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start
	
	org	0x100	; Main code starts here at address 0x100
delay: 
	decfsz 0x20, A ; decrement until zero
	bra delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	decfsz 0x21, A ; decrement until zero
	bra delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	movlw 0xFF ;proxy for length of delay
	movwf 0x21, A ; store 0x10 in FR 0x20
	decfsz 0x22, A ; decrement until zero
	bra delay
	return
delay2: 
	decfsz 0x20, A ; decrement until zero
	bra delay2
	return
start:
	movlw 	0x0
	movwf	TRISC, A	    ; Port C all outputs
	movlw 	0x0
	movwf	PORTC, A	    ; Port C all outputs
	movlw 	0x0
	movwf	PORTD, A	    ; Port C all outputs
	movlw 	0x1
	movwf	TRISD, A	    ; Port D all inputs
	movff   PORTD, 0x23, A
	bra 	test
	
loop:
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	;create delay
	movlw 0xFF
	movwf 0x21, A ; store 0x10 in FR 0x21
	movff 0x23, 0x22
	call delay
	movff 	0x06, PORTC
	incf 	0x06, W, A
	
	
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movlw 	0xFF
	cpfsgt 	0x06, A
    	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start
	end	main
