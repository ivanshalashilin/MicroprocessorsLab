#include <xc.inc>

global Servo_Setup, Pulse5Times, LongDelay17, Delay_17
global Delay_Count_Inner_FiveSixths, Delay_Count_Outer_FiveSixths, Delay_FiveSixths
global ShortDelay, OverallCount, HighCount, LowCount, TempCount, NumberofPulses
    
psect	      udata_acs   
PlaceHolder2: ds 1
Delay_Count_Inner_FiveSixths:  ds 1
Delay_Count_Outer_FiveSixths:  ds 1
ShortDelay: ds 1
OverallCount: ds 1
HighCount: ds 1 
LowCount:  ds 1
TempCount:  ds 1
DebugCount: ds 1
NumberofPulses: ds 1
LongDelayCount: ds 1
 
psect	servo_code, class=CODE
Servo_Setup:
    movlw 0x80
    movwf HighCount
    ; set PORTD to output
    movlw 11111110
    movwf TRISD, A
    movlw 00000000
    movwf PORTD, A
    movlw 0x0A
    movwf NumberofPulses
    return

Pulse5Times:
    decfsz NumberofPulses
    bra servo_loop
    movlw 0x32
    movwf NumberofPulses
    return
    


servo_loop:
    ;pulse high
    movlw 0x01
    movwf PORTD, A
    ;call 0.83ms high
    call Delay_FiveSixths
    call AfterFiveSixthsSetup
    ;call some number of 83 highs
    ;call some number of 83 lows
    ;call the 17.83ms delay - 
    movlw 0x00
    movwf PORTD, A
    call Delay_17
    movlw  0x04
    
    ;goto debugLoop
    return
    
Delay_FiveSixths:
    ;delay setup
    movlw 0x13
    movwf Delay_Count_Outer_FiveSixths
    movlw 0x50
    movwf Delay_Count_Inner_FiveSixths
    bra   Servo_Delay_Outer
    return

Servo_Delay_Outer:  
    decfsz  Delay_Count_Outer_FiveSixths, A 
    bra     Servo_Delay_Inner ; 2 cycles
    return

Servo_Delay_Inner:
    decfsz  Delay_Count_Inner_FiveSixths, A	; decrement until zero
    bra	    Servo_Delay_Inner    ;2 cycles
    movlw   0xFF ; 1 cycle
    movwf   Delay_Count_Inner_FiveSixths ; 1 cycle
    bra	    Servo_Delay_Outer ;2 cycles
    

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
    ;same code as Delay_FiveSixths, but for 533.6 = 534 = 0x216 cycles
    movlw 0x02
    movwf Delay_Count_Outer_FiveSixths
    movlw 0x16
    movwf Delay_Count_Inner_FiveSixths
    bra   Servo_Delay_Outer
    return
    
LongDelay17:
    movlw 0x50
    movwf LongDelayCount
LongDelay17Loop:
    call Delay_17
    decfsz LongDelayCount
    bra LongDelay17Loop
    return
    
    

    
AfterFiveSixthsSetup:
                movff HighCount, TempCount ;2 cycles
BigLoop:
                decfsz TempCount, 1, 0     ;1 cycle or 2 if final
                call CC83DelayStart ;2 cycles
		movlw 0x00
		cpfseq TempCount
		bra BigLoop
		;Start Low
                movlw 0b11111110
                movwf PORTD
                call PWMLowSetup
		return

CC83DelayStart: ;83 cycles total
                movlw 0x18 ;1 cycle
                movwf ShortDelay ;1cycle
                ;rounding-ones
                movlw 0xFF ;1 cycle
                movlw 0x00 ;1 cycle
                ;79 cycles
CC83Delay:
                decfsz ShortDelay, 1, 0       ;1 cycle or 2 if final
                bra CC83Delay                     ;2 cycles
                return

PWMLowSetup:
		movlw 0xFF
		subwf HighCount, 0
		movwf TempCount
		decfsz TempCount, 1, 0     ;1 cycle or 2 if final
                call CC83DelayStart ;2 cycles
		movlw 0x00
		cpfseq TempCount
                call CC83DelayStart ;2 cycles
		return
                
    


