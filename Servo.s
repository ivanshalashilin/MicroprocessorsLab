#include <xc.inc>

global Servo_Setup
global Delay_Count_Inner_FiveSixths, Delay_Count_Outer_FiveSixths
    
psect	      udata_acs   
Delay_Count_Inner_FiveSixths:  ds 1
Delay_Count_Outer_FiveSixths:  ds 1
 
psect	Servo_code, class=CODE
    
Servo_Setup:
    ; set PORTD to output
    movlw 11111110
    movwf TRISD, A
    movwf PORTD, A
    call Delay_FiveSixths
    return
    
Delay_FiveSixths:
    ;delay setup
    movlw 0x10
    movwf Delay_Count_Outer_FiveSixths
    movlw 0x10
    movwf Delay_Count_Inner_FiveSixths
    bra   Servo_Delay_Outer
    return

Servo_Delay_Outer:  
    decfsz  Delay_Count_Outer_FiveSixths, A
    bra     Servo_Delay_Inner
    bra    Servo_Delay_Outer
    return

Servo_Delay_Inner:
    decfsz  Delay_Count_Inner_FiveSixths, A	; decrement until zero
    bra	    Servo_Delay_Inner
    movlw   0xFF
    movwf   Delay_Count_Inner_FiveSixths
    return  
    

    


