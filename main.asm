;****************************************
; Test code for PIC10F220
; it just blinks a LED
;****************************************

#include p10f220.inc

      __CONFIG    _CP_OFF & _WDT_OFF & _IOFSCS_4MHZ & _MCLRE_ON   
      
      ; GLOBAL VARIABLES
t_w     EQU         0x10
      
      ; CODE
      ORG         0x000
      ; calibrate oscillator
      movwf       OSCCAL
      goto        init        ; jump to hardware initialization code
      
wait_w500us
      movwf       t_w
w5_o  movlw       .240        ; actually 522us [4 * PRESC * (256 - 240)] + 10
      movwf       TMR0        ; PRESC = 8 (see line 32)
w5_i  movf        TMR0, 0
      btfss       STATUS, Z
      goto        w5_i
      decfsz      t_w, 1
      goto        w5_o
      retlw       0

init
      ; configure part
      movlw       b'11000010' ; see datasheet
      option
      ; setup I/O pins
      movlw       0
      movwf       GPIO
      movlw       0           ; all pins output
      tris        GPIO
      ; setup adc
      movlw       0           ; disable
      movwf       ADCON0

zero
      bsf         GPIO, 2
      movlw       .1          ; 500us = 0°
      call        wait_w500us
      bcf         GPIO, 2
      movlw       .38         ; 39 * 0.522 = 20.358ms
      call        wait_w500us
      ; WAIT some time
      ; check for input
      ; btfss     GPIO, FOO
      goto        zero
max
      bsf         GPIO, 2
      movlw       .4          ; 2500us = 180°
      call        wait_w500us
      bcf         GPIO, 2
      movlw       .35         ; 39 * 0.522 = 20.358ms
      call        wait_w500us
      btfsc      GPIO, 3
      ; DEBOUNCE
      goto        max
      
      END
