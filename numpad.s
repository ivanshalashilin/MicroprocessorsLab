#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_Send_Byte_D
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
;psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
psect	code, abs	
	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	LCD_Setup	; setup UART
	;Enable the pull-up resistors on bits 0-3 of PORTE 
	movlw 0xff
	movwf 0x35
	
	movlw 0x11
	movwf 0x40, A	;decrementer to move to next lcd line

	goto	start
start:
	banksel PADCFG1
	bsf     REPU;, PADCFG1
	banksel 0x0
	;write 0s to LATE
	clrf	LATE, A
	movlw	0x0F
	movwf	TRISE, A
	
	;begin delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	call delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	call delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	call delay
	;end delay
	
	movlw 0x00
	movwf 0xAA
	
	movff PORTE, 0x31, A
	
	clrf  LATE, A
	
	movlw 0xF0
	movwf TRISE, A
	
	;begin delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	call delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	call delay
	movlw 0xFF ;proxy for length of delay
	movwf 0x20, A ; store 0x10 in FR 0x20
	call delay
	;end delay
	
	movff PORTE, 0x32, A
	clrf  LATE, A
	
	;add the two adresses together, move this to PORTD
	clrf  TRISD, A ;set it all to ouputs
	movlw 0x0
	addwf 0x31, 0, 0
	addwf 0x32, 0, 0
;	sublw 0xFF
	movwf PORTD, A
	
	;Check if no buttons pressd (Null)
	movlw 0xff
	cpfseq PORTD, A
	goto  checkIfNullPrior
	movlw 0xff
	movwf 0x35, A
	goto start

	
checkIfNullPrior:
	;Check if same button pressed
	movlw 0xff
	cpfseq 0x35, A
	goto start
	movlw 0x00
	movwf 0x35
	goto checkAllNums
	
	
	
	


	
	
	
checkAllNums:
	movlw 0x0
	movwf 0x33
	movlw 0x0
	addwf PORTD, 0, 0
	movwf 0x34, A
	call ifeq0
	call ifeq1
	call ifeq2
	call ifeq3
	call ifeq4
	call ifeq5
	call ifeq6
	call ifeq7
	call ifeq8
	call ifeq9
	call ifeqa
	call ifeqb
	call ifeqc
	call ifeqd
	call ifeqe
	call ifeqf
    
    
    

FoundValueOrCheckedAll:
	;MoveASCII to LCD if not null/ if 0xFF
	
	;null ascii check:
	movlw 0x0
	cpfseq 0x33
	goto checkLCDRow
	goto start
	
checkLCDRow:	
	decfsz 0x40, A
	goto sendSignal
	;ChangeRow
	
	movlw 11000000B 
	call  LCD_Send_Byte_I
	;once sent, 
	movlw 0xff
	movwf 0x40
	goto sendSignal
	
	
sendSignal:
	;create delay
	;movlw 0xFF 
	;movwf 0x20, A 
	;movlw 0xFF
	;movwf 0x21, A 
	;call delaylong
	
	movff  0x33, WREG
	call  LCD_Send_Byte_D
	
	
	    
	
	goto	start
	
	    
	    
	;and connect the 4 pins of the keyboard. 
    
    
	;Configure these pins as inputs, the 4 lines will be held 
	;high by the pull-up resistors.
	
ifeq0:
    movlw 0xBE
    cpfseq PORTD, A
    return
    movlw 0x30
    movwf 0x33
    goto FoundValueOrCheckedAll
	
ifeq1:
    movlw 0x77
    cpfseq PORTD, A
    return
    movlw 0x31
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeq2:
    movlw 0xB7
    cpfseq PORTD, A
    return
    movlw 0x32
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeq3:
    movlw 0xD7
    cpfseq PORTD, A
    return
    movlw 0x33
    movwf 0x33
    goto FoundValueOrCheckedAll
    

ifeq4:
    movlw 0x7B
    cpfseq PORTD, A
    return
    movlw 0x34
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeq5:
    movlw 0xBB
    cpfseq PORTD, A
    return
    movlw 0x35
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeq6:
    movlw 0xDB
    cpfseq PORTD, A
    return
    movlw 0x36
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeq7:
    movlw 0x7D
    cpfseq PORTD, A
    return
    movlw 0x37
    movwf 0x33
    goto FoundValueOrCheckedAll


ifeq8:
    movlw 0xBD
    cpfseq PORTD, A
    return
    movlw 0x38
    movwf 0x33
    goto FoundValueOrCheckedAll


ifeq9:
    movlw 0xDD
    cpfseq PORTD, A
    return
    movlw 0x39
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeqa:
    movlw 0x7E
    cpfseq PORTD, A
    return
    movlw 0x41
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeqb:
    movlw 0xDE
    cpfseq PORTD, A
    return
    movlw 0x42
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeqc:
    movlw 0xEE
    cpfseq PORTD, A
    return
    movlw 0x43
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeqd:
    movlw 0xED
    cpfseq PORTD, A
    return
    movlw 0x44
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeqe:
    movlw 0xEB
    cpfseq PORTD, A
    return
    movlw 0x45
    movwf 0x33
    goto FoundValueOrCheckedAll

ifeqf:
    movlw 0xE7
    cpfseq PORTD, A
    return
    movlw 0x46
    movwf 0x33
    goto FoundValueOrCheckedAll
    
;checkPriorNull:
;    movlw 0xff
;    cpfseq 0x35, A
;    goto start
;    goto checkAllNums

delay: 
	decfsz 0x20, A ; decrement until zero
	bra delay
	return
	
	

delaylong: 
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
	return

	end	rst