; AsmMemoGame.asm
; Created: 3/16/2018 8:30:36 AM


	; configurations
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
	ldi r16, 0x00						; seting value 0b0000_0000 into register 16
	out ddrb, r16						; setting all the bits in port b to be an input
	
	
start:									; game begins

	; initial game setup
.equ seq_counter = 3					; variable to count the number of steps in the sequence, initially set to 3
.equ sequence_start = 0x200				; giving an address for the sequence in RAM (0x200)

	call	welcome						; playing the welcome sequence

	clr		r1							; clear r1
	push	r1							; push r1 onto stack
	call	get_input					; wait for user input to start the game
	pop		r1							; return value, the value the user has entered

	call	lights_all_off				; switch all lights off 
	; delay 
	ldi		r21, 80		
	push	r21							; push parameter 1 to the stack (parameter = 80)
	call	delay						; call subroutine delay with parameter 80
	pop		r21 

.equ seq_value = 4						; setting the value that will go into the sequence (this should be random later on)

	ldi xh, high(sequence_start)		; loading the high part of sequence into X pointer
	ldi xl, low(sequence_start)			; loading the low part of sequence into X pointer
	ldi r16, seq_counter				; the sequence counter loaded into r16

	; loop to load the initial values in sequence
	; for (int i = 0; i < seqCounter; i++) {
	;	sequence[i] = ranGen.nextInt(9)
	;}	
								
	ldi r18, seq_value					; load the sequence value into r18	
seq_loading:
	st x+, r18							; store one sequence value into RAM 
	inc r18								; give new value to the variable value (this should be random later on)
	dec r16								; increment loop counter
	brne seq_loading					; jump to seq_loading if loop counter < seq counter

	clr r0								; tracker for the level
	ldi r16, seq_counter
	add r0, r16							; load the initial sequence counter into the tracker

next_level:
	push r0								; load the level counter as a parameter
	call sequence						; display the sequence for the player
	pop r0

	ldi		xh, high(sequence_start)	; loading the high part of sequence address into X pointer register
	ldi		xl, low(sequence_start)		; loading the low part of sequence address into X pointer register

	mov r17, r0							; copy the lenght of seq into r17

com_loop:
	clr		r1							; clear r1
	push	r1							; push r1 onto stack
	call	get_input					; wait for user input to start the game
	pop		r1							; return value, the value the user has entered

	ld r23, x+							; transfer one part of sequence into gpr
	cp r1, r23							; compare input with sequence
	brne error_seq						; branch to error if sequences weren't equal

	dec r17								; decrement loop counter
	tst r17
	brne com_loop

	inc r0								; increment the level counter
	ldi r19, 3
	push r19
	call inc_seq
	pop r19

error_seq:
	call error
	ldi		r21, 20		
	push	r21							; push parameter 1 to the stack 
	call	delay						; call subroutine delay with parameter
	pop		r21
	rjmp start

; add one more seq number
inc_seq:
	push r16
	in		zh, sph						
	in		zl, spl						; copy stack pointer value into z pointer
	adiw	zl, 1+3+1					; increment the z pointer up until parameter 1
	ld		r16, z+						; load random number into r16 form parameter

	st x+, r16							; store the next seq value into RAM
	pop r16
	ret
; end of add one more seq number	
	
; error sequence
error:
push r16			; use r16 as a counter
ldi r16, 4			; counter to repeat the error loop 4 times

error_loop:
	call lights_all_off

	ldi		r21, 20		
	push	r21							; push parameter 1 to the stack (parameter = 80)
	call	delay						; call subroutine delay with parameter 80
	pop		r21

	call lights_all_on

	ldi		r21, 20		
	push	r21							; push parameter 1 to the stack (parameter = 80)
	call	delay						; call subroutine delay with parameter 80
	pop		r21

	dec r16							; decrement counter
	tst r16							; test if r16 = 0
	brne error_loop					; branch if r16 is != 0
	pop r16
	ret
; end of error seq

; welcome sequence	
welcome:
	push r17
	push r18
	push r19
	push r20

	ldi r19, 8							; loop counter for all 7 LEDs
	ldi r18, 0x01						; value to add, to light sequentially each LED// the resulted value must be complemented for LED to light	
load_welcome:	
	add r17, r18						; r17 = 00 + 01 = 0000_0001  
	mov r20, r17						; move value to r20
	com r20								; value is inverted for LED0 to light
	out porta, r20						; value is outputted to porta

	ldi		r21, 20		
	push	r21							; push parameter 1 to the stack (parameter = 80)
	call	delay						; call subroutine delay with parameter 80
	pop		r21

	lsl r18								; r18 = 01 + 01 = 0000_0010 
	dec r19								; decrement loop counter

	brne load_welcome					; if r19-- != 0 , branch to load_welcome

	pop r20
	pop r19
	pop r18
	pop r17
	ret
; end of welcome sequence

	; add one more to sequence - generation of a new sequence number; increment sequence counter

get_random:
	push r16						; r16 used to store upper bound = 8
	ldi r16, 8						; load upper bound to r16

modulo:
	lsr r24							; logical shift right - divides number by two
	cp r24, r16
	brsh modulo
	
	st x+, r24						; store new sequence value into RAM 
	inc r17							; increment loop counter
	pop r16


	jmp start							; game is restarted



	; play sequence subroutine
	; param:
	;	- sequence counter;
sequence:
	push	r26
	push	r27
	push	r16
	push	r20

	ldi		xh, high(sequence_start)		; loading the high part of sequence into X pointer
	ldi		xl, low(sequence_start)		; loading the low part of sequence into X pointer

	in		zh, sph						
	in		zl, spl						; copy stack pointer value into z pointer
	adiw	zl, 4+3+1					; increment the z pointer up until parameter 1

	ld		r16, z+						; load counter for loop1 into r16 form parameter

seq_display:
	ld		r20, x+					; transfer one part of sequence into r20
	push	r20						; load r20 on the stack as a variable to light_on subroutine (which led to light)
	call	light_on				; call light_on routine with the values stored in the sequence
	pop		r20						; 

	ldi		r21, 80		
	push	r21						; push parameter 1 to the stack (parameter = 80)
	call	delay					; call subroutine delay with parameter 80
	pop		r21 

	call	lights_all_off			; switch all lights off 

	dec		r16					; increment loop counter
	brne	seq_display				; jump to seq_display if loop counter < seq counter

	pop		r20
	pop		r16
	pop		r27
	pop		r26
	ret


	; delay subroutine
	; parameter:
	;	number of outer loops between 1 and 255
delay:									
	push	r23							; push the value of r23 to the stack
	push	r24							; push the value of r24 to the stack
	push	r25							; push the value of r25 to the stack
	push	r30
	push	r31							; push the value of z pointer to the stack

	in		zh, sph						
	in		zl, spl						; copy stack pointer value into z pointer
	adiw	zl, 5+3+1					; increment the z pointer up until parameter 1

	ld		r23, z+						; load counter for loop1 into r23 form parameter
loop1:
	ldi		r24, 255					; load counter for loop2 into r24 = 255
loop2:
	ldi		r25, 255					; load counter for loop3 into r25 = 255
loop3:
	dec		r25							; decrement counter for loop3
	brne	loop3						; jump to loop3 label if r25 != 0
	dec		r24							; decrement counter for loop2
	brne	loop2						; jump to loop2 label if r24 != 0
	dec		r23							; decrement counter for loop1
	brne	loop1						; jump to loop1 label if r23 != 0

	pop		r31							; pop the value of z pointer from the stack
	pop		r30
	pop		r25							; pop the value of r25 from the stack
	pop		r24							; pop the value of r24 from the stack
	pop		r23							; pop the value of r23 from the stack
	
	ret									; end of delay subroutine

	; turn off all the lights
lights_all_off:
	push	r16					
	ldi		r16, 0x00			; set all 0 in the r16
	com		r16					; invert the pattern
	out		porta, r16			; send it to port 16
	pop		r16
	ret
		 
	; turn on all the lights
lights_all_on:
	push	r16				
	ldi		r16, 0xff			; set all 1 in the r16
	com		r16					; invert the pattern
	out		porta, r16			; send it to port 16
	pop		r16
	ret

	; turn on one individual light
	; param: 
	;	lights on between 0-7
light_on:
	push	r16
	push	r17
	push	r18
	push	r30
	push	r31
	
	in		zh, sph						
	in		zl, spl				; copy stack pointer value into z pointer
	adiw	zl, 5+3+1			; increment the z pointer up until parameter 1
		
	in		r17, porta			; read the input we have sent to port a
	com		r17
	ld		r16, z+				; load the parameter from the stack into r16
	ldi		r18, 1				; store 1 in r18
loop:
	tst		r16					; test if r16 = 0
	breq	shift_end			; break the loop if r16 = 0
	lsl		r18					; lsl - logic shift left
	dec		r16					; decrement the value 
	rjmp	loop				; jump to loop
shift_end:
	or		r17, r18			; 'or' current state of the lights with the value in r18
	com		r17					; invert the pattern before out
	out		porta, r17			; send the new pattern into porta

	pop		r31
	pop		r30
	pop		r18
	pop		r17
	pop		r16
	ret

	; get user input
	; the program stays here until the user enters some input
	; return:
	;	the user input
get_input:
	push r16
	push r17
	push r22
	push r30
	push r31

	in		zh, sph						
	in		zl, spl					; copy stack pointer value into z pointer
	adiw	zl, 5+3+1				; increment the z pointer up until return value

	clr r16							; clear r16 - random counter

loop_wait:
	inc r16							; increment r16 - random counter
	in r22, pinb					; read input from port b
	com r22						; inverse the input
	tst r22							; compare if there is any input
	breq loop_wait					; if input = 0 get input again

	clr r17
	push r17
	push r22
	call input_status
	pop r22
	pop r17

	st z, r17						; set up the input value from the user on the stack

	pop r31
	pop r30
	pop r22
	pop r17
	pop r16
	ret

; input status

input_status:

	push	r16
	push	r17
	push	r30
	push	r31

	in zh, sph						
	in zl, spl					; copy stack pointer value into z pointer
	adiw zl, 4+3+1				; increment the z pointer up until return value

	clr	r17
	ld r16, z+
	;com r16

next:
	lsr	r16
	tst	r16
	breq status_end
	inc	r17
	rjmp next
status_end:

	st z, r17
	pop r31
	pop r30
	pop r17
	pop	r16

	ret

; GENERATE A (pseudo)RANDOM NO
	load_generator:	
	mov r25, r21						; copy randomNo to r21
	rol r25								; Shifts all bits in r25 one place to the left. The C Flag is shifted into bit 0 of r25. Bit 7 is shifted into the C Flag.
	ror r21								; Shifts all bits in r21 one place to the right. The C Flag is shifted into bit 7 of r21. Bit 0 is shifted into the C Flag.
	eor r25,r21							; Performs the logical EOR between the contents of register 24 and register 21 and places the result in the destination register 24.
	out porta, r25						;//Testing purpose

