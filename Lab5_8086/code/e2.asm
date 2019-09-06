.include "m16def.inc"
.DEF temp=r16
.DEF c=r21

start:
	ldi r24 , low(RAMEND) ; initialize stack pointer
  	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	clr temp			;orismos thuras eisodou
	out DDRB,temp
	dec temp
	out DDRA,temp		;orismos thuras eksodou
	;out PORTB,temp
	in temp,PINB		;diavasma apo eisodo B
	mov YL,temp			;ekxorhsh dedomenon eisodou st a1--4 lsb aforoun svhsimo
	lsr temp					
	lsr temp
	lsr temp
	lsr	temp			;olisthhsh 4 theseis oste sta lsb na erthoun ta 4 msb
	mov XL,temp			;4 msb aforoun annama
	andi XL,15			;apomonosh 4 lsb --stoixeia anammatos
	andi YL,15			;apomonosh 4 lsb-- stoixeia svhsimatos
	lsl XL              ;(h add XL,XL)	praksh 2x g annama
	lsl YL              ;(h add YL,YL)	praksh 2x g svhsimo
	inc XL				;praksh (2x+1) g anamma
	inc YL				;praksh (2x+1) g svhsimo
	ldi c,50			;(2x+1)*50 msec
	mul c,XL			;r0 low, r1 high
	movw XL,r0			;r0-> a1(low), r1->a2(high)
	mul c,YL			
	movw YL,r0			;r0-> b1(low), r1->b2(high)
	
flash: 
    on:
		ser temp
		out PORTA,temp
		movw r24,XL    ;o diplos r24:r25 pairnei tin word tou XL
		rcall wait_msec ;h kathusterhsh tha klhsei XL fores
		
	off:
		clr temp
		out PORTA,temp
		movw r24,YL    ;o diplos r24:r25 pairnei tin word tou YL
		rcall wait_msec ;kathusterhsh tha klhthei YL fores
		rjmp start

;sunarthsh pou prokalei 1*(r24:r25) usec kathusterhsh
wait_usec:
		sbiw r24 ,1 
		nop           ;kathe nop prokalei 0.125usec delay 
		nop 
		nop 
		nop 
		brne wait_usec 
		ret 

;sunarthsh pou kalei thn wait_usec gia na petuxei delay 1msec
;sugkekrimena prokalei delaey = 2.125usec(17 CC) + 998.375usec(h wait_usec me eisodo 998) = 1.0005 msec
wait_msec:
		push r24 
		push r25 
		ldi r24 , low(998) 
		ldi r25 , high(998) 
		rcall wait_usec 
		pop r25 
		pop r24
		sbiw r24 , 1
		brne wait_msec 
		ret 
