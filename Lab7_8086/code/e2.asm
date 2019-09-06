.DSEG
_tmp_:.byte 2	
.CSEG
.include "m16def.inc"			
.def temp=r16
.def cnt=r17
.def leds=r18
.org 0x0
	jmp start
.org 0x10
	jmp ISR_TIMER1_OVF      ; etiketa sthn opoia 8a paei to programma otan teleiwsoun ta 4 sec tou timer

start:
	ldi temp,high(RAMEND)				;stoiva
	out sph,temp
	ldi temp,low(RAMEND)
	out spl,temp

	;arxikopoihsh keypad
	ldi temp,(1 << PC7)|(1 << PC6)|(1 << PC5)|(1 << PC4)
	out DDRC,temp
	;arxikopoihsh lcd
	ldi temp,(1 << PD7)|(1 << PD6)|(1 << PD5)|(1 << PD4)|(1 << PD3)|(1 << PD2)
	out DDRD,temp

	clr temp						;orismos A san eisodo gia na elegxoume tous diakoptes
	out DDRA,temp
	ser temp
	out DDRB,temp					;orismos B san eksodo sta leds 

	rcall lcd_init					;arxikopoihseis othonhs
	
activation:
	in temp,PINA
	cpi temp, 0x00					;elegxos an exoume energopoihsh
	ldi temp,0x85			;arxikopoihsh oste meta apo 4 sec na kanei uperxeilhsh
	out TCNT1H,temp			;65536 - 4*7812.5=  34.286 kai se hex einai iso me 85EE
	ldi temp,0xEE
	out TCNT1L,temp

	breq activation					;an den exei energopoihthei perimenei

	ldi temp,(1 << TOIE1)	;xrhsh timer
	out TIMSK, temp
	ldi temp, (1 << CS12)|(0 << CS11)|(1 << CS10)	;CLK/1024
	out TCCR1B ,temp		;f=8MHz--->8/1024=7812.5 Hz
	sei

	
	;rcall clean
	clr cnt					;metrhths gia 3 arithmous
read:
	ldi r24,low(20)
	ldi r25,high(20)
	rcall scan_keypad_rising_edge
	rcall keypad_to_ascii
	cpi r24,0			;an den paththei tipota
	breq read
	push r24
	rcall lcd_data
	pop r24
	inc cnt
	cpi cnt,0x03		;an den exoun diavastei kai ta 3 stoixeia sunexise
	brne cont
	clr cnt				;an exouun diavastei 3 stoixeia, clear ton counter kai katharise thn othonh an teleiwsei o xronos twn 4 sec kai den exw to swsto apotelesma xtypaei o sunagermos
	;rcall lcd_init
	rjmp read
cont:
	cpi r24,'D'		;  elegxw an exei patithei to plhktro D ths bardias mas 
	breq wait3
	rjmp read

wait3:
	ldi r24,low(20)
	ldi r25,high(20)
	rcall scan_keypad_rising_edge
	rcall keypad_to_ascii
	cpi r24,0			;an den paththei tipota
	breq wait3
	push r24
	rcall lcd_data
	pop r24
	inc cnt
	cpi cnt,0x03
	brne cont2        
	clr cnt
	;rcall lcd_init
cont2:
	cpi r24, '0'
	breq wait4			; an exei patithei to plhktro 0 
	rjmp read

wait4:
	ldi r24,low(20)
	ldi r25,high(20)
	rcall scan_keypad_rising_edge
	rcall keypad_to_ascii
	cpi r24,0			;an den paththei tipota
	breq wait4
	push r24
	rcall lcd_data		;den vazo inc cnt gt gia na exo ftasei edo exo upoxreotika diavasei 3 arithmous.
	pop r24
	cpi r24, '6'		; an exei patithei to plhktro 6
	breq alarmoff
	clr cnt				;an o kodikos p exoume eisagei den einai sostos katharise othonh kai cnt kai ksana
	;rcall lcd_init
	rjmp read
alarmoff:
	cli					;apenergopoihsh diakopon etsi wste na apenergopoih8ei kai o timer kai na paramenei sthn o8onh to mhnuma "ALARM OFF"
	
off:  ;efoson path8ei o swstos sundiasmos plhktrwn anabei sthn o8onh to alarm off 
	rcall lcd_init
	ldi r24,'a'		;A
	rcall lcd_data
	ldi r24,'l'		;L
	rcall lcd_data
	ldi r24,'a'		;A
	rcall lcd_data
	ldi r24,'r'		;R
	rcall lcd_data
	ldi r24,'m'		;M
	rcall lcd_data
	ldi r24,' '		;(space)
	rcall lcd_data
	ldi r24,'o'		;O
	rcall lcd_data
	ldi r24,'f'		;F
	rcall lcd_data
	ldi r24,'f'		;F
	rcall lcd_data
	rjmp off

ISR_TIMER1_OVF:     ; molis teleiwsoun ta 4 sec tou timer kai den exei path8ei o swstos sundiasmos plhktrwn bgazw sthn o8onh to mhnuma " ALARM ON " 
	rcall lcd_init
	ldi r24,'a'		;A
	rcall lcd_data
	ldi r24,'l'		;L
	rcall lcd_data
	ldi r24,'a'		;A
	rcall lcd_data
	ldi r24,'r'		;R
	rcall lcd_data
	ldi r24,'m'		;M
	rcall lcd_data
	ldi r24,' '		;(space)
	rcall lcd_data
	ldi r24,'o'		;O
	rcall lcd_data
	ldi r24,'n'		;N
	rcall lcd_data		
	
on_off:
	ser leds		
	out PORTB,leds	
	ldi r24,low(200)
	ldi r25,high(200)
	rcall wait_msec
	clr leds		
	out PORTB,leds	
	ldi r24,low(200)
	ldi r25,high(200)
	rcall wait_msec
	rjmp on_off
	reti			

scan_row:
	ldi r25 ,0x08		; a?????p???s? µe ?0000 1000?
back_: 
	lsl r25		; a??ste?? ???s??s? t?? ?1? t?se? ??se??
	dec r24				; ?s?? e??a? ? a???µ?? t?? ??aµµ??
	brne back_
	out PORTC ,r25		; ? a?t?st???? ??aµµ? t??eta? st? ?????? ?1?
	nop
	nop					; ?a??st???s? ??a ?a p????ße? ?a ???e? ? a??a?? ?at?stas??
	in r24 ,PINC		; ep?st??f??? ?? ??se?? (st??e?) t?? d?a??pt?? p?? e??a? p?esµ????
	andi r24 ,0x0f		; ap?µ??????ta? ta 4 LSB ?p?? ta ?1? de?????? p?? e??a? pat?µ????
ret						; ?? d?a??pte?.

scan_keypad:
	ldi r24 ,0x01		; ??e??e t?? p??t? ??aµµ? t?? p???t????????
	rcall scan_row
	swap r24			; ap????e?se t? ap?t??esµa
	mov r27 ,r24		; sta 4 msb t?? r27
	ldi r24 ,0x02		; ??e??e t? de?te?? ??aµµ? t?? p???t????????
	rcall scan_row
	add r27 ,r24		; ap????e?se t? ap?t??esµa sta 4 lsb t?? r27
	ldi r24 ,0x03		; ??e??e t?? t??t? ??aµµ? t?? p???t????????
	rcall scan_row
	swap r24			; ap????e?se t? ap?t??esµa
	mov r26 ,r24		; sta 4 msb t?? r26
	ldi r24 ,0x04		; ??e??e t?? t?ta?t? ??aµµ? t?? p???t????????
	rcall scan_row
	add r26 ,r24		; ap????e?se t? ap?t??esµa sta 4 lsb t?? r26
	movw r24 ,r26		; µet?fe?e t? ap?t??esµa st??? ?ata????t?? r25:r24
ret

scan_keypad_rising_edge:
	mov r22 ,r24		; ap????e?se t? ????? sp??????sµ?? st?? r22
	rcall scan_keypad	; ??e??e t? p???t??????? ??a p?esµ????? d?a??pte?
	push r24			; ?a? ap????e?se t? ap?t??esµa
	push r25
	mov r24 ,r22		; ?a??st???se r22 ms (t?p???? t?µ?? 10-20 msec p?? ?a?????eta? ap? t??
	ldi r25 ,0			; ?atas?e?ast? t?? p???t???????? ? ?????d????e?a sp??????sµ??)
	rcall wait_msec
	rcall scan_keypad	; ??e??e t? p???t??????? ?a?? ?a?
	pop r23				; ap?????e ?sa p???t?a eµfa??????
	pop r22				; sp??????sµ?
	and r24 ,r22
	and r25 ,r23
	ldi r26 ,low(_tmp_)	; f??t?se t?? ?at?stas? t?? d?a??pt?? st??
	ldi r27 ,high(_tmp_) ; p??????µe?? ???s? t?? ???t??a? st??? r27:r26
	ld r23 ,X+
	ld r22 ,X
	st X ,r24			; ap????e?se st? RAM t? ??a ?at?stas?
	st -X ,r25			; t?? d?a??pt??
	com r23
	com r22				; ß?e? t??? d?a??pte? p?? ????? «µ????» pat??e?
	and r24 ,r22
	and r25 ,r23
	ret

keypad_to_ascii: ; ?????? ?1? st?? ??se?? t?? ?ata????t? r26 d???????
	movw r26 ,r24 ; ta pa?a??t? s?µß??a ?a? a???µ???
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
	sbrc r26 ,3 ; a? de? e??a? ?1?pa?a??µpte? t?? ret, a????? (a? e??a? ?1?)
	ret ; ep?st??fe? µe t?? ?ata????t? r24 t?? ASCII t?µ? t?? D.
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
	sbrc r27 ,0 ; ta pa?a??t? s?µß??a ?a? a???µ???
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
	sbiw r24 ,1 ; 2 ?????? (0.250 µsec)
	nop ; 1 ?????? (0.125 µsec)
	nop ; 1 ?????? (0.125 µsec)
	nop ; 1 ?????? (0.125 µsec)
	nop ; 1 ?????? (0.125 µsec)
	brne wait_usec ; 1 ? 2 ?????? (0.125 ? 0.250 µsec)
	ret ; 4 ?????? (0.500 µsec)

wait_msec:
	push r24 ; 2 ?????? (0.250 µsec)
	push r25 ; 2 ??????
	ldi r24 , low(998) ; f??t?se t?? ?ata?. r25:r24 µe 998 (1 ?????? - 0.125 µsec)
	ldi r25 , high(998) ; 1 ?????? (0.125 µsec)
	rcall wait_usec ; 3 ?????? (0.375 µsec), p???a?e? s??????? ?a??st???s? 998.375 µsec
	pop r25 ; 2 ?????? (0.250 µsec)
	pop r24 ; 2 ??????
	sbiw r24 , 1 ; 2 ??????
	brne wait_msec ; 1 ? 2 ?????? (0.125 ? 0.250 µsec)
	ret ; 4 ?????? (0.500 µsec)
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
	
	ldi r24,0x0d
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

