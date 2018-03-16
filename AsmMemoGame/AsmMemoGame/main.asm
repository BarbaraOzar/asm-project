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
.equ loop_delay_counter1 = 25				; creating variable to hold the counter for the most inner loop in the delay method

start:										; game begins
											; initial game setup
.equ seq_counter = 3						; variable to count the number of steps in the sequence, initially set to 3
.equ sequence = 0x03						; giving an adress for the sequence in r3 (should be in ram (0x200))
.equ seq_value = 1							; setting the value that will go into the sequence (this should be random later on)

	ldi r18, seq_counter					; the sequence counter loaded into r18
		

		; loop to load the initial 3 values in sequence
		; for (int i = 0; i < seqCounter; i++) {
		;	sequence[i] = ranGen.nextInt(9);
		;}

		; problem with the loop, it always stores the value in the same address: how to increment the adress? 
		; when we do we have to transfer the sequence in ram

	ldi r17, 0								; load the counter for the loop into r17								
	ldi r16, seq_value						; load the sequence value into r16
seq_loading:
	sts sequence + 1, r16					; store one sequence value (+1 works! How to add the content of r17 (counter)????????
	inc r16									; give new value to the variable value (this should be random later on)
	inc r17									; increment loop counter
	cp r17, r18								; compare loop counter with seq counter
	brlo seq_loading						; jump to seq_loading if loop counter < seq counter





	jmp start								; game is restarted


delay:										; creating a method delay to be called when needed
	ldi r29, 255							; load counter for loop1 into r29
loop1:
	ldi r30, 255							; load counter for loop2 into r30
loop2:
	ldi r31, loop_delay_counter1			; load counter for loop3 into r31
loop3:
	dec r31									; decrement counter for loop3
	brne loop3								; jump to loop3 label if r31 != 0
	dec r30									; decrement counter for loop2
	brne loop2								; jump to loop2 label if r30 != 0
	dec r29									; decrement counter for loop1
	brne loop1								; jump to loop1 label if r29 != 0
	ret



