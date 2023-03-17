#include <xc.inc>
    
global GetDecimalDigits
global RES3, RES2, RES1, RES0, RES38, RES28, RES18, RES08
global OUT3, OUT2, OUT1, OUT0
psect	      udata_acs  ; named variables in access ram
; Multiply1616
PlaceHolder:	ds 1
RES3:	ds 1	; reserve 1 byte for variable LCD_cnt_l
RES2:	ds 1	; reserve 1 byte for variable LCD_cnt_h
RES1:	ds 1	; reserve 1 byte for ms counter
RES0:	ds 1	; reserve 1 byte for temporary use
ARG1L:  ds 1
ARG2L:  ds 1
ARG1H:  ds 1
ARG2H:  ds 1
; Multiply824
RES38:	ds 1	; reserve 1 byte for counting through nessage
RES28:	ds 1 
RES18:	ds 1
RES08:  ds 1
ARG1L8: ds 1
ARG2H8: ds 1
ARG2M8: ds 1
ARG2L8: ds 1
; Output
OUT3:   ds 1
OUT2:   ds 1
OUT1:   ds 1
OUT0:   ds 1
; Clear Carry
CarryClr: ds 1

psect	mutliply_code, class=CODE
Multiply1616:
    MOVLW  0x00
    MOVWF  CarryClr
    MOVLW  0x00
    ADDWFC CarryClr
    
    
    MOVF    ARG1L, W
    MULWF   ARG2L ; ARG1L * ARG2L->
    ; PRODH:PRODL
    MOVFF   PRODH, RES1 ;
    MOVFF   PRODL, RES0 ;
    ;
    MOVF    ARG1H, W
    MULWF   ARG2H ; ARG1H * ARG2H->
    ; PRODH:PRODL
    MOVFF   PRODH, RES3 ;
    MOVFF   PRODL, RES2 ;
    ;
    MOVF    ARG1L, W
    MULWF   ARG2H ; ARG1L * ARG2H->
    ; PRODH:PRODL
    MOVF    PRODL, W ;
    ADDWF   RES1, F ; Add cross
    MOVF    PRODH, W ; products
    ADDWFC  RES2, F ;
    CLRF    WREG ;
    ADDWFC  RES3, F ;
    ;
    MOVF    ARG1H, W ;
    MULWF   ARG2L ; ARG1H * ARG2L->
    ; PRODH:PRODL
    MOVF    PRODL, W ;
    ADDWF   RES1, F ; Add cross
    MOVF    PRODH, W ; products
    ADDWFC  RES2, F ;
    CLRF    WREG ;
    ADDWFC  RES3, F ;
    return

Multiply824:
    MOVLW  0x00
    MOVWF  CarryClr
    MOVLW  0x00
    ADDWFC CarryClr
    
    MOVF    ARG1L8, W
    MULWF   ARG2L8

    MOVFF   PRODH, RES18
    MOVFF   PRODL, RES08 ;

    MOVF    ARG1L8, W
    MULWF   ARG2H8

    MOVFF   PRODH, RES38
    MOVFF   PRODL, RES28

    MOVF    ARG1L8, W
    MULWF   ARG2M8

    MOVF    PRODL, W
    ADDWF   RES18, F
    MOVF    PRODH, W
    ADDWFC  RES28, F
    CLRF    WREG
    ADDWFC  RES38, F

    ;MOVF    ARG1H8
    ;MULWF   ARG2L8

;    MOVF    PRODL, W
;    ADDWF   RES18, F
;    MOVF    PRODH, W
;    ADDWFC  RES28, F
;    CLRF    WREG ;
;    ADDWFC  RES38, F ;
    
    return

GetDecimalDigits:
    MOVFF ADRESH, ARG1H
    MOVFF ADRESL, ARG1L
    
    MOVLW 0x41
    MOVWF ARG2H
    MOVLW 0x8A
    MOVWF ARG2L

    call  Multiply1616
    ;call  PrintResult1616
    MOVFF  RES3, OUT3

    MOVLW 0x0A
    MOVWF ARG1L8

    MOVFF  RES2, ARG2H8
    MOVFF  RES1, ARG2M8
    MOVFF  RES0, ARG2L8

    call   Multiply824
;    call   PrintResult824
    MOVFF  RES38, OUT2
    MOVFF  RES28, ARG2H8
    MOVFF  RES18, ARG2M8
    MOVFF  RES08, ARG2L8

    call   Multiply824
;    call   PrintResult824
    MOVFF  RES38, OUT1
    MOVFF  RES28, ARG2H8
    MOVFF  RES18, ARG2M8
    MOVFF  RES08, ARG2L8

    call   Multiply824
    
    MOVFF  RES38, OUT0
    
    return
    
PrintResult824:
    MOVFF  RES38, 0x61
    MOVFF  RES28, 0x62
    MOVFF  RES18, 0x63
    MOVFF  RES08, 0x64
    return

PrintResult1616:
    MOVFF  RES3, 0x61
    MOVFF  RES2, 0x62
    MOVFF  RES1, 0x63
    MOVFF  RES0, 0x64
    return