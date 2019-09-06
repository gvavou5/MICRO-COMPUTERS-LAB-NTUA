.DSEG
_tmp_:.byte 2	
.CSEG
.include "m16def.inc"			
.def temp=r16

start:
	ldi temp,high(RAMEND)				;stoiva
	out sph,temp
	ldi temp,low(RAMEND)
	out spl,temp

	;arxikopoihsh keypad
	ldi temp,(1 << PC7)|(1 << PC6)|(1 << PC5)|(1 << PC4)
	out DDRC,temp
	; arxikopoihsh othonis
	ldi temp,(1 << PD7)|(1 << PD6)|(1 << PD5)|(1 << PD4)|(1 << PD3)|(1 << PD2)
	out DDRD,temp
	
	rcall lcd_init					;arxikopoihseis othonhs
	rcall none
	
		
read:
	ldi r24,low(20)					;xronoi gia
	ldi r25,high(20)				;spinthhrismous
	rcall scan_keypad_rising_edge	;anagnosh keypad
	rcall keypad_to_ascii			;epistrofh ascii plhktrou pou paththhke
	cpi r24,0						;an den diavasei tipota, ksanadiavase
	breq read
	push r24
	push r25
	rcall lcd_init						;katharise thn othonh
	pop r25
	pop r24
	rcall lcd_data					;display
	rjmp read


	
none:
	ldi r24,'N'		;N
	rcall lcd_data  ; kalw thn lcd_data poy moy emfanizei sthn o8onh to dedomeno pou einai apo8hkeumeno ston r24
	ldi r24,'O'		;O
	rcall lcd_data
	ldi r24,'N'		;N
	rcall lcd_data
	ldi r24,'E'		;E
	rcall lcd_data
	ret	

scan_row:
	ldi r25 ,0x08		; a?????p???s? �e ?0000 1000?
back_: 
	lsl r25		; a??ste?? ???s??s? t?? ?1? t?se? ??se??
	dec r24				; ?s?? e??a? ? a???�?? t?? ??a��??
	brne back_
	out PORTC ,r25		; ? a?t?st???? ??a��? t??eta? st? ?????? ?1?
	nop
	nop					; ?a??st???s? ??a ?a p?????e? ?a ???e? ? a??a?? ?at?stas??
	in r24 ,PINC		; ep?st??f??? ?? ??se?? (st??e?) t?? d?a??pt?? p?? e??a? p?es�????
	andi r24 ,0x0f		; ap?�??????ta? ta 4 LSB ?p?? ta ?1? de?????? p?? e??a? pat?�????
	ret.

scan_keypad:
	ldi r24 ,0x01		; ??e??e t?? p??t? ??a��? t?? p???t????????
	rcall scan_row
	swap r24			; ap????e?se t? ap?t??es�a
	mov r27 ,r24		; sta 4 msb t?? r27
	ldi r24 ,0x02		; ??e??e t? de?te?? ??a��? t?? p???t????????
	rcall scan_row
	add r27 ,r24		; ap????e?se t? ap?t??es�a sta 4 lsb t?? r27
	ldi r24 ,0x03		; ??e??e t?? t??t? ??a��? t?? p???t????????
	rcall scan_row
	swap r24			; ap????e?se t? ap?t??es�a
	mov r26 ,r24		; sta 4 msb t?? r26
	ldi r24 ,0x04		; ??e??e t?? t?ta?t? ??a��? t?? p???t????????
	rcall scan_row
	add r26 ,r24		; ap????e?se t? ap?t??es�a sta 4 lsb t?? r26
	movw r24 ,r26		; �et?fe?e t? ap?t??es�a st??? ?ata????t?? r25:r24
	ret

scan_keypad_rising_edge:
	mov r22 ,r24		; ap????e?se t? ????? sp??????s�?? st?? r22
	rcall scan_keypad	; ??e??e t? p???t??????? ??a p?es�????? d?a??pte?
	push r24			; ?a? ap????e?se t? ap?t??es�a
	push r25
	mov r24 ,r22		; ?a??st???se r22 ms (t?p???? t?�?? 10-20 msec p?? ?a?????eta? ap? t??
	ldi r25 ,0			; ?atas?e?ast? t?? p???t???????? ? ?????d????e?a sp??????s�??)
	rcall wait_msec
	rcall scan_keypad	; ??e??e t? p???t??????? ?a?? ?a?
	pop r23				; ap?????e ?sa p???t?a e�fa??????
	pop r22				; sp??????s�?
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_)	; f??t?se t?? ?at?stas? t?? d?a??pt?? st??
	ldi r27 ,high(_tmp_) ; p??????�e?? ???s? t?? ???t??a? st??? r27:r26
	ld r23 ,X+
	ld r22 ,X
	st X ,r24			; ap????e?se st? RAM t? ??a ?at?stas?
	st -X ,r25			; t?? d?a??pt??
	com r23
	com r22				; ??e? t??? d?a??pte? p?? ????? ��????� pat??e?
	and r24 ,r22
	and r25 ,r23
	ret

keypad_to_ascii: ; ?????? ?1? st?? ??se?? t?? ?ata????t? r26 d???????
	movw r26 ,r24 ; ta pa?a??t? s?�???a ?a? a???�???
	ldi r24 ,'*'
	sbrc r26 ,0
	ret
	ldi r24 ,'0'
	sbrc r26 ,1
	ret
	ldi r24 ,'#'
	sbrc r26 ,2
	ret
	ldi r24 ,'D'
	sbrc r26 ,3 ; a? de? e??a? ?1?pa?a??�pte? t?? ret, a????? (a? e??a? ?1?)
	ret ; ep?st??fe? �e t?? ?ata????t? r24 t?? ASCII t?�? t?? D.
	ldi r24 ,'7'
	sbrc r26 ,4
	ret
	ldi r24 ,'8'
	sbrc r26 ,5
	ret
	ldi r24 ,'9'
	sbrc r26 ,6
	ret
	ldi r24 ,'C'
	sbrc r26 ,7
	ret
	ldi r24 ,'4' ; ?????? ?1? st?? ??se?? t?? ?ata????t? r27 d???????
	sbrc r27 ,0 ; ta pa?a??t? s?�???a ?a? a???�???
	ret
	ldi r24 ,'5'
	sbrc r27 ,1
	ret
	ldi r24 ,'6'
	sbrc r27 ,2
	ret
	ldi r24 ,'B'
	sbrc r27 ,3
	ret
	ldi r24 ,'1'
	sbrc r27 ,4
	ret
	ldi r24 ,'2'
	sbrc r27 ,5
	ret
	ldi r24 ,'3'
	sbrc r27 ,6
	ret
	ldi r24 ,'A'
	sbrc r27 ,7
	ret
	clr r24
	ret

wait_usec:
	sbiw r24 ,1 ; 2 ?????? (0.250 �sec)
	nop ; 1 ?????? (0.125 �sec)
	nop ; 1 ?????? (0.125 �sec)
	nop ; 1 ?????? (0.125 �sec)
	nop ; 1 ?????? (0.125 �sec)
	brne wait_usec ; 1 ? 2 ?????? (0.125 ? 0.250 �sec)
	ret ; 4 ?????? (0.500 �sec)

wait_msec:
	push r24 ; 2 ?????? (0.250 �sec)
	push r25 ; 2 ??????
	ldi r24 , low(998) ; f??t?se t?? ?ata?. r25:r24 �e 998 (1 ?????? - 0.125 �sec)
	ldi r25 , high(998) ; 1 ?????? (0.125 �sec)
	rcall wait_usec ; 3 ?????? (0.375 �sec), p???a?e? s??????? ?a??st???s? 998.375 �sec
	pop r25 ; 2 ?????? (0.250 �sec)
	pop r24 ; 2 ??????
	sbiw r24 , 1 ; 2 ??????
	brne wait_msec ; 1 ? 2 ?????? (0.125 ? 0.250 �sec)
	ret ; 4 ?????? (0.500 �sec)

write_2_nibbles:
		push r24
		in r25,PIND
		andi r25,0x0f
		andi r24,0xf0
		add r24,r25
		out PORTD,r24
		sbi PORTD,PD3
		cbi PORTD,PD3
		pop r24
		swap r24
		andi r24,0xf0
		add r24,r25
		out PORTD,r24
		sbi PORTD,PD3
		cbi PORTD,PD3
		ret
		
		
lcd_data:
	sbi PORTD,PD2
	rcall write_2_nibbles
	ldi r24,43
	ldi r25,0
	rcall wait_usec
	ret
	
lcd_command:
	cbi PORTD,PD2
	rcall write_2_nibbles
	ldi r24,39
	ldi r25,0
	rcall wait_usec
	ret
	
lcd_init:
	ldi r24,40
	ldi r25,0
	rcall wait_msec
	
	ldi r24,0x30
	out PORTD,r24
	sbi PORTD,PD3
	cbi PORTD,PD3
	ldi r24,39
	ldi r25,0
	rcall wait_usec
	
	ldi r24,0x30
	out PORTD,r24
	sbi PORTD,PD3
	cbi PORTD,PD3
	ldi r24,39
	ldi r25,0
	rcall wait_usec
	
	ldi r24,0x20
	out PORTD,r24
	sbi PORTD,PD3
	cbi PORTD,PD3
	ldi r24,39
	ldi r25,0
	rcall wait_usec
	
	ldi r24,0x28
	rcall lcd_command
	
	ldi r24,0x0c
	rcall lcd_command
	
	ldi r24,0x01
	rcall lcd_command
	ldi r24,low(1530)
	ldi r25,high(1530)
	rcall wait_usec
	
	ldi r24,0x06
	rcall lcd_command
	ldi r24,low(3900)
	ldi r25,high(3900)
	rcall wait_usec

	ret