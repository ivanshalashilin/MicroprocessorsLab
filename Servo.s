#include <xc.inc>

global Servo_Setup
global Delay_Count_Inner_FiveSixths, Delay_Count_Outer_FiveSixths
global ShortDelay, OverallCount, HighCount, LowCount, TempCount, PWMByte
    
psect	      udata_acs   
PlaceHolder2: ds 1
Delay_Count_Inner_FiveSixths:  ds 1
Delay_Count_Outer_FiveSixths:  ds 1
ShortDelay: ds 1
OverallCount: ds 1
HighCount: ds 1 
LowCount:  ds 1
TempCount:  ds 1
PWMByte: ds 1
 
psect	servo_code, class=CODE
Servo_Setup:
    ; set PORTD to output
    movlw 11111110
    movwf TRISD, A
    ;pulse high
    movlw 00000001
    movwf PORTD, A
    ;call 0.83ms high
    call Delay_FiveSixths
    ;call some number of 83 highs
    ;call some number of 83 lows
    ;call the 17.83ms delay -  
    call Delay_17
    movlw  0x04
    
    return
    
Delay_FiveSixths:
    ;delay setup
    movlw 0x34
    movwf Delay_Count_Outer_FiveSixths
    movlw 0x16
    movwf Delay_Count_Inner_FiveSixths
    bra   Servo_Delay_Outer
    return

Servo_Delay_Outer:  
    decfsz  Delay_Count_Outer_FiveSixths, A
    bra     Servo_Delay_Inner
    return

Servo_Delay_Inner:
    decfsz  Delay_Count_Inner_FiveSixths, A	; decrement until zero
    bra	    Servo_Delay_Inner
    movlw   0xFF
    movwf   Delay_Count_Inner_FiveSixths
    bra	    Servo_Delay_Outer
    

Delay_17: ;not important how long this is, as long as within operating frequeny.
    ; if anything should be shorter if it doesn't work 
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths 
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    call Delay_FiveSixths   
    ;same code as Delay_FiveSixths, but for 533.6 = 534 = 0x216 cycles
    movlw 0x02
    movwf Delay_Count_Outer_FiveSixths
    movlw 0x16
    movwf Delay_Count_Inner_FiveSixths
    bra   Servo_Delay_Outer
    return
    
    
    
    
PWMHighSetup:
                movff HighCount, TempCount ;2 cycles
                decfsz TempCount, 1, 0     ;1 cycle or 2 if final
                bra 83CCDelayStart ;2 cycles
                movlw 0b11111110
                movwf PWMByte
                call PWMLowSetup

83CCDelayStart: ;83 cycles total
                movlw 0x19 ;1 cycle
                movwf ShortDelay ;1cycle
                ;rounding-ones
                movlw 0xFF ;1 cycle
                movlw 0x00 ;1 cycle
                ;79 cycles

83CCDelay:

                decfsz ShortDelay, 1, 0       ;1 cycle or 2 if final
                bra 83CCDelay                     ;2 cycles
                return

PWMLowSetup:
                movff LowCount, TempCount ;2 cycles
                decfsz TempCount, 1, 0     ;1 cycle or 2 if final
                bra 83CCDelayStart ;2 cycles 
                call LongLow         ;2 cycles
    


