;****************************************
; PIC10F220                             *
; Ultimate Machine firmware source code *
;****************************************

#include p10f220.inc

      __CONFIG    _CP_OFF & _WDT_OFF & _IOFSCS_4MHZ & _MCLRE_ON   
      ; -------------------------------
      ; GLOBAL VARIABLES
      ; -------------------------------
t_w         EQU         0x10        ; temporary store location for w register
lwait       EQU         0x11        ; countdown for delays
servo_pos   EQU         0x12        ; store current servo position
      ; -------------------------------
      ; CONSTANT VALUES
      ; -------------------------------
      #define TMR_START_VAL   .100
      ; -------------------------------
      ; PIN ASSIGNMENT
      ; -------------------------------
      #define SWITCH    GPIO,0
      #define GND_CTR   GPIO,1
      #define SERVO     GPIO,2
      ; -------------------------------
      ; CODE
      ; -------------------------------
      ORG         0x000
      
      movwf       OSCCAL
      goto        init
      
      ; send pulse to the servo.
      ; the angle is controlled by writing in W the desired position
      ; 1 -> -60°, 250-> 60° 
      ; (NOTE: if w > 250 or w = 0 the servo will self-destruct)
w_servo_pulse
      ; logic 1
      bsf         SERVO
      movwf       t_w
      movlw       .247         ; 250 - 3 instruction overhead
      movwf       lwait
      ; wait 1ms
tst   nop
      decfsz      lwait,f
      goto        tst
      ; wait w*4us
_4us  nop
      decfsz      t_w,f       ; waiting 4us more makes no difference
      goto        _4us        ; as we adjust the value above
      ; logic 0
      bcf         SERVO
      retlw       0

init  
      ; configure part
      movlw       b'11000110' ; see datasheet
      option
      ; setup I/O pins
      clrf        GPIO
      movlw       b'00000001' ; GPIO,0 (SWITCH) INPUT
      tris        GPIO
      ; disable adc
      clrf       ADCON0
      
main
      movlw       .1
      movwf       servo_pos
      
      movlw       TMR_START_VAL
      movwf       TMR0

tst2  movf        TMR0,w
      btfss       STATUS,Z
      goto        tst2
      
      movlw       TMR_START_VAL     ; reset timer
      movwf       TMR0
      ; timer has reached 0. Generate the pulse
      movf        servo_pos,w
      call        w_servo_pulse
      ; plenty of time left here (~17962 clock cycles)
      btfss       SWITCH            ; check for input
      goto        max
min
      movlw       .1
      movwf       servo_pos
      goto        tst2
max
      movlw       .250
      movwf       servo_pos
      goto        tst2
      
      END
