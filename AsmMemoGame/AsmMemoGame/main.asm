;
; AsmMemoGame.asm
;
; Created: 3/16/2018 8:30:36 AM
; Author : Talita
;


		; configuration of port
	ldi r16, 0xff							; seting value 0b1111_1111 into register 16
	out ddra, r16							; setting all the bits in port a to be an output
	out porta, r16							; turn off all leds

		; configuration of stack
	ldi r17, high(ramend)
	out sph, r17
	ldi r17, low(ramend)
	out spl, r17

		; configuration of variables
.equ loop_delay_counter1 = 25


delay:										; creating a method delay to be called when needed
	ldi r18, 255							; counter for loop1
loop1:
	ldi r19, 255							; counter for loop2
loop2:
	ldi r20, loop_delay_counter1			; counter for loop3
loop3:
	dec r20									; decrement counter for loop3
	brne loop3								; jump to loop3 label if r20 != 0
	dec r19									; decrement counter for loop2
	brne loop2								; jump to loop2 label if r19 != 0
	dec r18									; decrement counter for loop1
	brne loop1								; jump to loop1 label if r18 != 0
	ret



