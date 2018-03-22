;
; AsmMemoGame.asm
;
; Created: 3/16/2018 8:30:36 AM



; configuration of stack
	ldi r16, high(ramend)				
	out sph, r16						; loading the high end of stack pointer with 0x21
	ldi r16, low(ramend)
	out spl, r16						; loading the low end of stack pointer with 0xff

	; configuration of portA for output
	ldi r16, 0xff						; seting value 0b1111_1111 into register 16
	out ddra, r16						; setting all the bits in port a to be an output
	out porta, r16						; turn off all leds
	 
	; configuration of portB for input
	ldi r16, 0x0						; seting value 0b1111_1111 into register 16
	out ddrb, r16						; setting all the bits in port a to be an output
	out portb, r16						; turn off all leds

	;WELCOME SEQUENCE	
	ldi r19, 8							; loop counter for all 7 LEDs
	ldi r17, 0x00						; value has to be inverted for LEDs on
	ldi r18, 0x01						; value to add, to light sequentially each LED// the resulted value must be complemented for LED to light
	ldi r24, 0							; value to increment and use it to gerenate randomNo later						
	ldi r25, 0x0						; for randomGen

load_welcome:	
	add r17, r18						; r17 = 00 + 01 = 0000_0001  
	mov r20, r17						; move value to r20
	com r20								; value is inverted for LED0 to light
	out porta, r20						; value is outputted to porta

	add r18, r18						; r18 = 01 + 01 = 0000_0010 
	dec r19								; decrement loop counter
	
	call small_delay					; delay before second LED lightning 

	cpi r19, 0x00						; r19 > 0? 
	brne load_welcome					; if r19-- != 0 , branch to load_welcome
	
	rjmp wait_for_input					; check portb for input


	
	
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
		;	sequence[i] = ranGen.nextInt(9)
		;}	
								
	ldi r18, seq_value					; load the sequence value into r18
	ldi r17, 0							; load the counter for the loop into r17	
seq_loading:
	st x+, r18							; store one sequence value into RAM 
	inc r18								; give new value to the variable value (this should be random later on)
	inc r17								; increment loop counter

	cp r17, r16							; compare loop counter with seq counter
	brlo seq_loading					; jump to seq_loading if loop counter < seq counter


	; while the game is on
	ldi r19, 1							; load an indicator that the game is still on (1 = on, 0 = off)
nextLevel:

	; play sequence
	ldi xh, high(sequence)				; loading the high part of sequence into X pointer
	ldi xl, low(sequence)				; loading the low part of sequence into X pointer
	ldi r17, 0							; load the counter for the loop into r17
seq_display:
	ld r20, x+							; transfer one part of sequence into r20
	out porta, r20						; output value of r20 to led

	clr r21
	push r21							; place for return value in the stack
	ldi r21, 100
	push r21							; push parameter 1 to the stack (parameter = 100)
	call delay							; call subroutine delay with parameter 100
	pop r21
	pop r21								; no return value for delay subroutine

	inc r17								; increment loop counter
	cp r17, r16							; compare loop counter with seq counter
	brlo seq_display					; jump to seq_display if loop counter < seq counter
<<<<<<< HEAD

=======
		
>>>>>>> master
		; wait for user input

		; compare input with sequence

		; if wrong input => game over, error sequence

		; increment sequence counter

		; add one more to sequence


	jmp start							; game is restarted


delay:									; creating a subroutine delay to be called when needed
	push r23							; push the value in r23 to the stack
	push r24							; push the value in r24 to the stack
	push r25							; push the value in r25 to the stack

	in zh, sph						
	in zl, spl							; copy stack pointer value into z pointer
	adiw zl, 3+3+1						; increment the z pointer up until parameter 1

	ld r23, z+							; load counter for loop1 into r23 form parameter
loop1:
	ldi r24, 255						; load counter for loop2 into r24 = 255
loop2:
	ldi r25, 255						; load counter for loop3 into r25 = 255
loop3:
	dec r25								; decrement counter for loop3
	brne loop3							; jump to loop3 label if r25 != 0
	dec r24								; decrement counter for loop2
	brne loop2							; jump to loop2 label if r24 != 0
	dec r23								; decrement counter for loop1
	brne loop1							; jump to loop1 label if r23 != 0

	pop r25								; pop the value of r25 from the stack
	pop r24								; pop the value of r24 from the stack
	pop r23								; pop the value of r23 from the stack

	ret									; end of delay subroutine



;SMALL DELAY IN BETWEEN LEDs LIGHTNING:
small_delay:							; creating a method delay to be called when needed
	ldi r21, 10							; load counter for loop1 into r29 // values should be incresed by *10
loopsmall1:
	ldi r22, 255						; load counter for loop2 into r30  // values should be incresed by *10
loopsmall2:
	ldi r23, 255						; load counter for loop2 into r30  // values should be incresed by *10
loopsmall3:
	dec r23
	brne loopsmall3
	dec r22
	brne loopsmall2
	dec r21
	brne loopsmall1
	ret


;Check portB for input
wait_for_input:
	sbic pinb, 0
	rjmp load_generator	
	inc r25								; it increments only once?!
	rjmp wait_for_input
	
; GENERATE A (pseudo)RANDOM NO
	load_generator:	
	mov r25, r21						; copy randomNo to r21
	rol r25								; Shifts all bits in r25 one place to the left. The C Flag is shifted into bit 0 of r25. Bit 7 is shifted into the C Flag.
	ror r21								; Shifts all bits in r21 one place to the right. The C Flag is shifted into bit 7 of r21. Bit 0 is shifted into the C Flag.
	eor r25,r21							; Performs the logical EOR between the contents of register 24 and register 21 and places the result in the destination register 24.
	out porta, r25						;//Testing purpose

