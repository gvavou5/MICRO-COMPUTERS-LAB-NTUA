.include "m16def.inc"
.def curr =r16
.def counter =r17

start: 		ldi r24 , low(RAMEND)  ; initialize stack pointer
  			out SPL , r24
	    	ldi r24 , high(RAMEND)
	    	out SPH , r24
			clr r24				; initialize PORTA for input
			out DDRA , r24
			ser r24				; initialize PORTB for output
			out DDRB , r24
			;out PORTA , r24
			ldi curr,0x01
			out PORTB, curr
			ldi counter,0x07
			ldi r24 , low(500)	; load r25:r24 with 500
			ldi r25 , high(500)	; delay 0.5 second


left:		ldi r24 , low(500)	; load r25:r24 with 500
			ldi r25 , high(500)	; delay 0.5 second
			rcall wait_msec	; led goes from right to left
			sbic PINA,0X07		; check if Pa7 = 1
			rjmp left			; if it is 1 stop until it gets 0...
			out PORTB, curr		; show led 
			lsl curr			; else move left
			dec counter			; until it reaches the (left) end
			breq right
			rjmp left

right:  	ldi r24 , low(500)	; load r25:r24 with 500
			ldi r25 , high(500)	; delay 0.5 second
			rcall wait_msec	; led goes from left to right
			sbic PINA,0X07		; check if Pa7 = 1
			rjmp right			; if it is 1 stop until it gets 0...
			out PORTB, curr
			lsr curr			; else move right
			inc counter			; until it reaches the (right) end
			cpi counter,0x07
			breq left
			rjmp right

	
wait_usec:
		sbiw r24 ,1				; 2 ?????? (0.250 탎ec)
		nop						; 1 ?????? (0.125 탎ec)
		nop						; 1 ?????? (0.125 탎ec)
		nop						; 1 ?????? (0.125 탎ec)
		nop						; 1 ?????? (0.125 탎ec)
		brne wait_usec			; 1 ? 2 ?????? (0.125 ? 0.250 탎ec)
		ret						; 4 ?????? (0.500 탎ec)

wait_msec:
		push r24				; 2 ?????? (0.250 탎ec)
		push r25				; 2 ??????
		ldi r24 , low(998)		; f??t?se t?? ?ata?. r25:r24 킻 998 (1 ?????? - 0.125 탎ec)
		ldi r25 , high(998)		; 1 ?????? (0.125 탎ec)
		rcall wait_usec			; 3 ?????? (0.375 탎ec), p???a?e? s??????? ?a??st???s? 998.375 탎ec
		pop r25					; 2 ?????? (0.250 탎ec)
		pop r24					; 2 ??????
		sbiw r24 , 1			; 2 ??????
		brne wait_msec			; 1 ? 2 ?????? (0.125 ? 0.250 탎ec)
		ret						; 4 ?????? (0.500 탎ec)

