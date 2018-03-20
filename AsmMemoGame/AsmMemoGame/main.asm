;
; AsmMemoGame.asm
;
; Created: 3/16/2018 8:30:36 AM
; Author : Talita
;


		; configuration of port
	ldi r16, 0xff						; seting value 0b1111_1111 into register 16
	out ddra, r16						; setting all the bits in port a to be an output
	out porta, r16						; turn off all leds

		; configuration of stack
	ldi r16, high(ramend)				
	out sph, r16						; loading the high end of stack pointer with 0x21
	ldi r16, low(ramend)
	out spl, r16						; loading the low end of stack pointer with 0xff


start:									; game begins
										; initial game setup
.equ seq_counter = 3					; variable to count the number of steps in the sequence, initially set to 3
.equ seq_value = 1						; setting the value that will go into the sequence (this should be random later on)

.equ sequence = 0x200					; giving an adress for the sequence in RAM (0x200)
	ldi xh, high(sequence)				; loading the high part of sequence into X pointer
	ldi xl, low(sequence)				; loading the low part of sequence into X pointer

	ldi r16, seq_counter				; the sequence counter loaded into r16
		

		; loop to load the initial 3 values in sequence
		; for (int i = 0; i < seqCounter; i++) {
		;	sequence[i] = ranGen.nextInt(9);
		;}
	ldi r17, 0							; load the counter for the loop into r17								
	ldi r18, seq_value					; load the sequence value into r18
seq_loading:
	st x+, r18							; store one sequence value into RAM 
	inc r18								; give new value to the variable value (this should be random later on)
	inc r17								; increment loop counter
	cp r17, r16							; compare loop counter with seq counter
	brlo seq_loading					; jump to seq_loading if loop counter < seq counter

		; welcome sequence

		; while the game is on
nextLevel:
		; play sequence

		; wait for user input

		; compare input with sequence

		; if wrong input => game over, error sequence

		; increment sequence counter

		; add one more to sequence


	jmp start							; game is restarted


delay:									; creating a subroutine delay to be called when needed
	push r29							; push the value in r29 to the stack
	push r30							; push the value in r30 to the stack
	push r31							; push the value in r31 to the stack

	ldi r29, 25							; load counter for loop1 into r29
loop1:
	ldi r30, 255						; load counter for loop2 into r30
loop2:
	ldi r31, 255						; load counter for loop3 into r31
loop3:
	dec r31								; decrement counter for loop3
	brne loop3							; jump to loop3 label if r31 != 0
	dec r30								; decrement counter for loop2
	brne loop2							; jump to loop2 label if r30 != 0
	dec r29								; decrement counter for loop1
	brne loop1							; jump to loop1 label if r29 != 0

	pop r31								; pop the value of r31 from the stack
	pop r30								; pop the value of r30 from the stack
	pop r29								; pop the value of r29 from the stack

	ret



