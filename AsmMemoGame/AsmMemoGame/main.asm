; AsmMemoGame.asm
; Created: 3/16/2018 8:30:36 AM


; configurations
; configuration of stack
	ldi		r16, high(ramend)				
	out		sph, r16						; loading the high end of stack pointer with 0x21
	ldi		r16, low(ramend)
	out		spl, r16						; loading the low end of stack pointer with 0xff

; configuration of portA for output
	ldi		r16, 0xff						; seting value 0b1111_1111 into register 16
	out		ddra, r16						; setting all the bits in port a to be an output
	out		porta, r16						; turn off all leds
	 
; configuration of portB for input
	ldi		r16, 0x00						; seting value 0b0000_0000 into register 16
	out		ddrb, r16						; setting all the bits in port b to be an input


; game begins
start:									

; initial game setup
.equ seq_counter = 3						; initial count the number of steps in the sequence
.equ sequence_start = 0x200					; giving an address for the sequence in RAM (0x200)

	call	welcome							; playing the welcome sequence subroutine

	clr		r1								; clear r1 for return value of the user's input
	clr		r2								; clear r2 for return value of the random bit
	push	r2								; push r2 onto stack
	push	r1								; push r1 onto stack
	call	get_input						; wait for user input to start the game
	pop		r1								; return value, user input bit number
	pop		r2								; return value - random number

	call	lights_all_off					; reset the lights before playing the game sequence

	ldi		xh, high(sequence_start)		; loading the high part of sequence_start into X pointer
	ldi		xl, low(sequence_start)			; loading the low part of sequence_start into X pointer
	ldi		r16, seq_counter				; the sequence counter loaded into r16	
	
; loading the initial sequence with the size of seq_counter							
seq_loading:
	st		x+, r2							; store one sequence value into RAM and increase x pointer
	
	clr		r18								; clear r18 for return value for method initial_sequence_generation
	push	r18								; push r18 on the stack
	push	r2								; push the sequence value as a paramether for the method on the stack
	call	init_seq_gen					; call subroutine to generate random number
	pop		r2								; pop the parameter
	pop		r18								; pop the return value (random number) from the stack
	
	mov		r2, r18							; transfer the return value into r2 (next value to be added into the sequence)
	dec		r16								; decrement loop counter
	brne	seq_loading						; jump to seq_loading when loop counter reaches 0

	clr		r0								; tracker for the levels
	ldi		r16, seq_counter				; load the value of seq_counter into r16
	add		r0, r16							; level tracker starts with the initial value of seq_counter

next_level:
	push	r0								; load the levels counter as a parameter
	call	sequence						; display the sequence for the player
	pop		r0								; pop the parameter from the stack

	ldi		xh, high(sequence_start)		; loading the high part of sequence address into X pointer register
	ldi		xl, low(sequence_start)			; loading the low part of sequence address into X pointer register

	mov		r17, r0							; copy the lenght of sequence into r17 for loop counter
com_loop:
	clr		r1								; clear r1 for return value of the user's input
	clr		r2								; clear r2 for return value of the random bit
	push	r2								; push r2 onto stack
	push	r1								; push r1 onto stack
	call	get_input						; wait for user input to start the game
	pop		r1								; return value, user input bit number
	pop		r2								; return value - random number

	ld		r23, x+							; transfer one value of the sequence into GPR

	call	lights_all_off					; reset all lights

	ldi		r21, 10							; load parameter for delay subroutine
	push	r21								; push parameter to the stack 
	call	delay							; call subroutine delay with parameter
	pop		r21								; pop the parameter from the stack

	mov		r20, r23						; move into r20 the one value from the sequence
	push	r20								; load r20 on the stack as a variable to light_on subroutine (which led to light)
	call	light_on						; call light_on routine with the values stored in the sequence
	pop		r20								; pop the parameter from the stack

	ldi		r21, 30							; load parameter for delay subroutine
	push	r21								; push parameter to the stack 
	call	delay							; call subroutine delay with parameter
	pop		r21								; pop the parameter from the stack

	call	lights_all_off					; reset all lights

	cp		r1, r23							; compare input from the user with one sequence value
	brne	error_seq						; branch to error if values weren't equal

	dec		r17								; decrement loop counter
	tst		r17								; test if the loop counter have reached 0 (no more values to compare)
	brne	com_loop						; jump to com_loop if r17 != 0

	inc		r0								; increment the level counter
	st		x+, r2							; store the next seq value into RAM, random number, coming from get_input subroutine as a return value
	
	ldi		r21, 20							; load parameter for delay subroutine
	push	r21								; push parameter to the stack 
	call	delay							; call subroutine delay with parameter
	pop		r21								; pop the parameter from the stack

	rjmp	next_level						; jump to next level

error_seq:
	call	error

	ldi		r21, 20		
	push	r21								; push parameter 1 to the stack 
	call	delay							; call subroutine delay with parameter
	pop		r21
	call	lights_all_off
	rjmp	start


; error sequence subroutine
error:
push	r16									; use r16 as a counter
ldi		r16, 4								; counter to repeat the error loop 4 times

error_loop:
	call	lights_all_off

	ldi		r21, 20		
	push	r21								; push parameter 1 to the stack (parameter = 80)
	call	delay							; call subroutine delay with parameter 80
	pop		r21

	call	lights_all_on

	ldi		r21, 20		
	push	r21								; push parameter 1 to the stack (parameter = 80)
	call	delay							; call subroutine delay with parameter 80
	pop		r21

	dec		r16								; decrement counter
	tst		r16								; test if r16 = 0
	brne	error_loop						; branch if r16 is != 0
	pop		r16
	ret
; end of error sequence subroutine

; welcome sequence subroutine
welcome:
	push	r17
	push	r18
	push	r19
	push	r20
	clr		r17

	ldi		r19, 8							; loop counter for all 7 LEDs
	ldi		r18, 0x01						; value to add, to light sequentially each LED// the resulted value must be complemented for LED to light	
load_welcome:	
	add		r17, r18						; r17 = 00 + 01 = 0000_0001  
	mov		r20, r17						; move value to r20
	com		r20								; value is inverted for LED0 to light
	out		porta, r20						; value is outputted to porta

	ldi		r21, 20		
	push	r21								; push parameter 1 to the stack (parameter = 80)
	call	delay							; call subroutine delay with parameter 80
	pop		r21

	lsl		r18								; r18 = 01 + 01 = 0000_0010 
	dec		r19								; decrement loop counter

	brne	load_welcome					; if r19-- != 0 , branch to load_welcome

	pop		r20
	pop		r19
	pop		r18
	pop		r17
	ret
; end of welcome sequence subroutine

; play sequence subroutine
; parameter:
;	- sequence counter;
sequence:
	push	r26
	push	r27
	push	r16
	push	r20

	ldi		xh, high(sequence_start)		; loading the high part of sequence into X pointer
	ldi		xl, low(sequence_start)			; loading the low part of sequence into X pointer

	in		zh, sph						
	in		zl, spl							; copy stack pointer value into Z pointer
	adiw	zl, 4+3+1						; increment the Z pointer up until parameter 1

	ld		r16, z+							; load counter for loop1 into r16 form parameter

seq_display:
	ld		r20, x+							; transfer one part of sequence into r20
	push	r20								; load r20 on the stack as a variable to light_on subroutine (which led to light)
	call	light_on						; call light_on routine with the values stored in the sequence
	pop		r20						 

	ldi		r21, 30		
	push	r21								; push parameter 1 to the stack 
	call	delay							; call subroutine delay with parameter
	pop		r21 

	call	lights_all_off					; switch all lights off 

	ldi		r21, 10		
	push	r21								; push parameter 1 to the stack 
	call	delay							; call subroutine delay with parameter
	pop		r21

	dec		r16								; increment loop counter
	brne	seq_display						; jump to seq_display if loop counter < seq counter

	pop		r20
	pop		r16
	pop		r27
	pop		r26
	ret
; end of play sequence subroutine

; delay subroutine
; parameter:
;	- number of outer loops between 1 and 255
delay:									
	push	r23								; push the value of r23 to the stack
	push	r24								; push the value of r24 to the stack
	push	r25								; push the value of r25 to the stack
	push	r30
	push	r31								; push the value of z pointer to the stack

	in		zh, sph						
	in		zl, spl							; copy stack pointer value into z pointer
	adiw	zl, 5+3+1						; increment the z pointer up until parameter 1

	ld		r23, z+							; load counter for loop1 into r23 form parameter
loop1:
	ldi		r24, 255						; load counter for loop2 into r24 = 255
loop2:
	ldi		r25, 255						; load counter for loop3 into r25 = 255
loop3:
	dec		r25								; decrement counter for loop3
	brne	loop3							; jump to loop3 label if r25 != 0
	dec		r24								; decrement counter for loop2
	brne	loop2							; jump to loop2 label if r24 != 0
	dec		r23								; decrement counter for loop1
	brne	loop1							; jump to loop1 label if r23 != 0

	pop		r31								; pop the value of z pointer from the stack
	pop		r30
	pop		r25								; pop the value of r25 from the stack
	pop		r24								; pop the value of r24 from the stack
	pop		r23								; pop the value of r23 from the stack
	
	ret										; end of delay subroutine

; turn off all the lights subroutine
lights_all_off:
	push	r16					
	ldi		r16, 0x00						; set all 0 in the r16
	com		r16								; invert the pattern
	out		porta, r16						; send it to port 16
	pop		r16
	ret
		 
; turn on all the lights subroutine
lights_all_on:
	push	r16				
	ldi		r16, 0xff						; set all 1 in the r16
	com		r16								; invert the pattern
	out		porta, r16						; send it to port 16
	pop		r16
	ret

; turn on one individual light subroutine
; parameter: 
;	- led number between 0-7
light_on:
	push	r16
	push	r17
	push	r18
	push	r30
	push	r31
	
	in		zh, sph						
	in		zl, spl							; copy stack pointer value into Z pointer
	adiw	zl, 5+3+1						; increment the Z pointer up until parameter 1
		
	in		r17, porta						; read the input we have sent to port a
	com		r17								; complement the input 
	ld		r16, z+							; load the parameter from the stack into r16
	ldi		r18, 1							; store 1 in r18
loop:
	tst		r16								; test if r16 = 0
	breq	shift_end						; break the loop if r16 = 0
	lsl		r18								; lsl - logic shift left
	dec		r16								; decrement the value 
	rjmp	loop							; jump to loop
shift_end:
	or		r17, r18						; 'or' current state of the lights with the value in r18
	com		r17								; invert the pattern before out
	out		porta, r17						; send the new pattern into porta

	pop		r31
	pop		r30
	pop		r18
	pop		r17
	pop		r16
	ret
; end of turn on one individual light subroutine

; get user input subroutine
; the program stays here until the user enters some input
; return:
;	- the user input
;	- next random sequence value
get_input:
	push	r16
	push	r17
	push	r22
	push	r30
	push	r31

	in		zh, sph						
	in		zl, spl							; copy stack pointer value into Z pointer
	adiw	zl, 5+3+1						; increment the Z pointer up until return value
	clr		r16								; clear r16 - random number
	
loop_wait:
	inc		r16								; increment r16 - random number
	sbrc	r16, 3							; skip next line if r16 reached 8 -> 3rd bit (0000 1000)
	clr		r16								; if r16 reached 8 clear r16

	in		r22, pinb						; read input from port b
	com		r22								; inverse the input
	tst		r22								; compare if there is any input
	breq	loop_wait						; if input = 0 get input again

	clr		r17
	push	r17
	push	r22
	call	input_status					; call subroutine to determine which button was pressed
	pop		r22
	pop		r17

	st		z+, r17							; set up the input value from the user on the stack
	st		z, r16							; set up the random seq value on the stack 

	pop		r31
	pop		r30
	pop		r22
	pop		r17
	pop		r16
	ret
; end of get input subroutine

; input status subroutine 
; checks which button was pressed by user
input_status:
	push	r16
	push	r17
	push	r30
	push	r31

	in		zh, sph						
	in		zl, spl							; copy stack pointer value into Z pointer
	adiw	zl, 4+3+1						; increment the Z pointer up until return value

	clr		r17								; used to count which button was pressed
	ld		r16, z+

next:
	lsr		r16								; left shifts to determine which bit is set
	tst		r16								; tests if the value in r16 is = 0
	breq	status_end						; if r16 = 0 end shifting
	inc		r17								; counts how many times r16 was shifted
	rjmp	next

status_end:
	st		z, r17							; store the button's number onto stack
	pop		r31
	pop		r30
	pop		r17
	pop		r16
	ret
; end of input status subroutine

; generate (pseudo) random initial seq subroutine
init_seq_gen:	
	push	r21
	push	r22
	push	r25
	in		zh, sph						
	in		zl, spl							; copy stack pointer value into z pointer
	adiw	zl, 3+3+1						; increment the z pointer up until return value

	ld		r21, z+							; get parameter from stack
	inc		r21								; add one to get different number than 0 if initial is 0
	ldi		r22, 7							; 0b0000_0111 to AND it with pseudo random number to discard bits higher than 2nd	

	mov		r25, r21						; copy randomNo to r21
	rol		r25								; Shifts all bits in r25 one place to the left. The C Flag is shifted into bit 0 of r25. Bit 7 is shifted into the C Flag.
	ror		r21								; Shifts all bits in r21 one place to the right. The C Flag is shifted into bit 7 of r21. Bit 0 is shifted into the C Flag.
	eor		r25, r21						; Performs the logical EOR between the contents of register 25 and register 21 and places the result in the destination register 24.
	and		r25, r22						; performs logical AND operation on r25 and r22

	st		z, r25							; store return value onto stack
	pop		r25
	pop		r22
	pop		r21
	ret
; end of generate random initial seq subroutine
