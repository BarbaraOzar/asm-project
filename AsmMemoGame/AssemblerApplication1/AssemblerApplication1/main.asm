;
; AssemblerApplication1.asm
;
; Created: 18-03-2018 21:48:11
; Author : winpc
;

;
; AssemblerApplication1.asm
;
; Created: 18-03-2018 15:35:49
; Author : winpc
;


; Replace with your application code
	
; configuration of stack
	ldi r17, high(ramend)
	out sph, r17
	ldi r17, low(ramend)
	out spl, r17


; configuration of port
	ldi r16, 0xff				; seting value 0b1111_1111 into register 16
	out ddra, r16				; setting all the bits in port a to be output
	out porta, r16				; turn off all leds

; WELCOME SEQUENCE
	cbi porta, 0				; clear bit PA0 to light LED0 
	call delay					; delay before next operation
	cbi porta, 1	
	call delay
	cbi porta, 2	
	call delay
	cbi porta, 3	 
	call delay
	cbi porta, 4	
	call delay
	cbi porta, 5	
	call delay
	cbi porta, 6	
	call delay
	cbi porta, 7	
	call delay
	
	nop
	out porta, r16				; turn off all LEDs	
	call bigger_delay			; delay before memoryGame starts

; GENERATE A (pseudo)RANDOM NO
	ldi r18, 0xf0				; r18 = 11110000 as a pseudoRandom value
	rol r18						; Shifts all bits in Rd one place to the left. The C Flag is shifted into bit 0 of Rd. Bit 7 is shifted into the C Flag.
	ldi r19, 0x29				; r19 = 00101001 as a pseudoRandom value
	ror r19						; Shifts all bits in Rd one place to the right. The C Flag is shifted into bit 7 of Rd. Bit 0 is shifted into the C Flag.
	eor r18,r19					; Performs the logical EOR between the contents of register Rd and register Rr and places the result in the destination register Rd.
		
; START LOADING THE SEQUENCE
	.equ seq_counter = 3		; variable to count the number of steps in the sequence, initially set to 3
	.equ specific_bit = 0		; bit0 initially ; This value should be incremented, up to 7		

next_level:						; label used later, for next levels
	ldi r21, 0					; load the counter for the loop into r21								
	ldi r22, seq_counter		; load the sequence counter into r22	


seq_loading:
	out porta, r16				; make sure LEDs are off
	sbrs r18, specific_bit		; This instruction tests a single bit in a register and skips the next instruction if the bit is cleared.
	rjmp jump1					; extecutes if r18[specificBit] = 0
	rjmp jump2					; extecutes if r18[specificBit] = 1

jump1:	
	sbi porta, specific_bit		; set portA[specificBit] = 1 ; LED[specificBit] is off // maybe not needed this line of code?? 
	nop
	jmp jump_out				; breaks this loop
jump2:	
	cbi porta, specific_bit		; set portA[specificBit] = 0 ; LED[specificBit] is on 
	nop
jump_out:	
	call delay					; delay untill next portA[specificBit] is setted
	inc r21						; increment loop counter
	cp r21, r22					; compare loop counter with seq counter
	;specific_bit+1				; ?????? Possible to increment a value that is not storred to a register? 
								; ?????? If I store it into register, than I can not used it as a value for line 75: sbrs r18, specific_bit
	brlo seq_loading			; jump to seq_loading if loop counter < seq counter
	
; NEXT LEVEL	
	inc r22						; ????? Same here as line81
	rjmp next_level				; jumps to line58 // executes next level

;DELAY IN BETWEEN LEDs LIGHTNING:
delay:							; creating a method delay to be called when needed
	ldi r29, 20					; load counter for loop1 into r29 // values should be incresed by *10
loop1:
	ldi r30, 10					; load counter for loop2 into r30  // values should be incresed by *10
loop2:
	nop
	nop
	dec r30
	brne loop2
	dec r29
	brne loop1
	ret

;DELAY IN BETWEEN GAME's PARTS: (WELCOME SEQUENCE/ GAME SEQUENCE/ USER INPUT/ NEXT ROUND)
bigger_delay:					; creating a method delay to be called when needed
	ldi r29, 25					; load counter for loop1 into r29  // values should be incresed by *10
loop1a:
	ldi r30, 25					; load counter for loop2 into r30  // values should be incresed by *10
loop2a:
	nop
	nop
	dec r30
	brne loop2a
	dec r29
	brne loop1a
	ret	