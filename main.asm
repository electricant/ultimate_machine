;
; Firmware for PIC10F220 based ultimate machine.
; 
; * ----------------------------------------------------------------------------
; * "THE BEER-WARE LICENSE" (Revision 42):
; * <paoscr@gmail.com> wrote this file. As long as you retain this notice you
; * can do whatever you want with this stuff. If we meet some day, and you think
; * this stuff is worth it, you can buy me a beer in return. Pol
; * ----------------------------------------------------------------------------

#include p10f220.inc

      __CONFIG    _CP_OFF & _WDT_OFF & _IOFSCS_4MHZ & _MCLRE_ON   

; -------------------------------
;      GLOBAL VARIABLES
; -------------------------------
lwait        EQU    0x10	; countdown for delays
servo_pos    EQU    0x11	; store current servo position
; -------------------------------
;      CONSTANT VALUES
; -------------------------------
#define TMR_START_VAL    .100
#define SERVO_MIN        .1
#define SERVO_MAX        .250
; -------------------------------
;      PIN ASSIGNMENT
; -------------------------------
#define SWITCH    GPIO,0
#define SERVO     GPIO,1
#define PWR       GPIO,2
      
; -------------------------------
;      CODE
; -------------------------------
	ORG 0x000

	movwf	OSCCAL
	goto	init
      
	; send pulse to the servo.
	; the angle is controlled by writing in W the desired position
	; 1 -> -60°, 250-> 60° 
	; (NOTE: if w > 250 or w = 0 the servo will self-destruct)
servo_pulse
	; logic 1
	bsf	SERVO
	; wait 1ms	
	movlw	.247		; 250 - 3 instruction overhead
	movwf	lwait
_1ms	nop
	decfsz	lwait,f
	goto	_1ms
	; wait servo_pos*4us     
	movf	servo_pos,w
_4us	nop
	decfsz	W,f
	goto	_4us
      
	; logic 0
	bcf	SERVO
	retlw	0

init  
	; configure part
	movlw	b'11000110'	; Switch off everything we don't need
	option			; Timer prescaler is set to !:128
	clrf	ADCON0		; No ADC, please.
	clrf	GPIO
	movlw	b'00000001'	; GPIO,0 (SWITCH) INPUT
	tris	GPIO

main
	bsf	PWR		;  don't stop me now...

	movlw	TMR_START_VAL
	movwf	TMR0

	goto	min            ; start at minimum value

tst	movf	TMR0,w
	btfss	STATUS,Z
	goto	tst
	; timer has reached 0. Reset it and generate the pulse
	movlw	TMR_START_VAL
	movwf	TMR0

	call	servo_pulse
      ; plenty of time left here (~17962 clock cycles)
	btfss	SWITCH            ; check for input
	goto	max

min
	movlw	SERVO_MIN
	movwf	servo_pos
	goto	tst

max
	movlw	SERVO_MAX
	movwf	servo_pos
	goto	tst
      
	END
