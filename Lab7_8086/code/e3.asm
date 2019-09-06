.include "m16def.inc"
.def temp = r16
.def input = r17
.def ekat = r18
.def dek = r19
.def mon = r20
.def pros = r21
.def zero = r22
.def one = r23

	ldi r24 , low(RAMEND) ; initialize stack pointer
  	out SPL , r24
	ldi r24 , high(RAMEND)
	out SPH , r24
	ldi one,1
	clr temp			  ; orismos PortB ws thura eisodou
	out DDRB,temp
	ser temp
	out DDRC,temp
	ldi zero,0
	
	; arxikopoihsh lcd display
	ldi temp,(1 << PD7)|(1 << PD6)|(1 << PD5)|(1 << PD4)|(1 << PD3)|(1 << PD2)
	out DDRD,temp

	;rcall lcd_init		  ; arxikopoiisi lcd othonis
	;ldi r24,'!'
	;rcall lcd_data
main:
	rcall lcd_init		  ; arxikopoiisi lcd othonis
	in input,PINB
	;out PORTC,input
	mov temp,input
	andi temp,0x80
	cpi temp,0x80
	breq negative		  ; ean o arithmos einai arnhtikos phgaine sto negative
	ldi pros,'+'	  ; emfanise to prosimo +
	mov temp,input
	rjmp compute		  ; kai sunexise se upologismous
negative:	
	ldi pros,'-'	  ; alliws o arnhtikos exei -
	mov temp,input
	com temp
	add temp,one			  ; vres to sumpl. ws pros 2 tou ari8mou  dhadh antestrepse ton kai pros8ese to 1 etsi wste na ginei sthn synexeia h swsth metatroph tou bin se dec kata apoluth timh 
	rjmp compute		  ; kai sunexise se upologismous

	
; Apeikonish dyadikou arithmou se dekadikh morfh
compute:
	ldi ekat,0
	ldi dek,0
	ldi mon,0
	cpi temp,100
	brlo dekades		  ; an temp < 100 kane upologismo dekadwn
	inc ekat
	subi temp,100
dekades:
	cpi temp,10
	brlo monades
	inc dek
	subi temp,10
	rjmp dekades
monades:
	mov mon,temp		 ; oti perissepse einai monades
	ldi temp,8

display:      ;emfanish ths duadikhs timhs tou ari8mou ka8e fora gia ta 8 bit kanw ena shift aristera na apomonwsw to ka8e bit kai to emfanizw seiriaka sthn o8onh 
	ldi r24,'0' ; bazw ston r24 arxika ton ascii code tou 0 (8elw o r24 na exei eite ton ascii code tou 1 eite tou 0)
	lsl input
	adc r24,zero
	rcall lcd_data
	dec temp
	breq next
	rjmp display
next:                ; h synarthsh lcd_data pernei ton ascii code pou exei o kataxwrhths r24 kai ton emfanizei sthn o8onh gi auto kai prin apo ka8e emfanish apo8hkeuw ton ascii code tou '0'ston r24 etsi wste telika na dhmiourgh8ei o swstos ascii code tou ari8mou pou 8elw na emfanisw  
	ldi r24,'='
	rcall lcd_data  
	mov r24,pros    
	rcall lcd_data
	ldi r24,'0'
	add r24,ekat
	rcall lcd_data
	ldi r24,'0'
	add r24,dek
	rcall lcd_data
	ldi r24,'0'
	add r24,mon
	rcall lcd_data
	rjmp main


wait_usec:
		sbiw r24 ,1 
		nop 
		nop 
		nop 
		nop 
		brne wait_usec 
		ret 

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

write_2_nibbles: 
	push r24 
	in r25 ,PIND 
	andi r25 ,0x0f 
	andi r24 ,0xf0 
	add r24 ,r25  
	out PORTD ,r24  
	sbi PORTD ,PD3  
	cbi PORTD ,PD3  
	pop r24  
	swap r24  
	andi r24 ,0xf0  
	add r24 ,r25 
	out PORTD ,r24 
	sbi PORTD ,PD3  
	cbi PORTD ,PD3 
	ret 

lcd_data: 
	sbi PORTD ,PD2  
	rcall write_2_nibbles  
	ldi r24 ,43  
	ldi r25 ,0  
	rcall wait_usec 
	ret 

lcd_command: 
	cbi PORTD ,PD2  
	rcall write_2_nibbles  
	ldi r24 ,39  
	ldi r25 ,0  
	rcall wait_usec 
	ret 

lcd_init: 
	ldi r24 ,40 
	ldi r25 ,0  
	rcall wait_msec  
	ldi r24 ,0x30  
	out PORTD ,r24  
	sbi PORTD ,PD3  
	cbi PORTD ,PD3  
	ldi r24 ,39 
	ldi r25 ,0  
	rcall wait_usec  
	ldi r24 ,0x30 
	out PORTD ,r24 
	sbi PORTD ,PD3
	cbi PORTD ,PD3 
	ldi r24 ,39 
	ldi r25 ,0 
	rcall wait_usec 
	ldi r24 ,0x20 
	out PORTD ,r24 
	sbi PORTD ,PD3 
	cbi PORTD ,PD3 
	ldi r24 ,39 
	ldi r25 ,0 
	rcall wait_usec 
	ldi r24 ,0x28  
	rcall lcd_command  
	ldi r24 ,0x0c  
	rcall lcd_command 
	ldi r24 ,0x01  
	rcall lcd_command 
	ldi r24 ,low(1530) 
	ldi r25 ,high(1530) 
	rcall wait_usec 
	ldi r24 ,0x06  
	rcall lcd_command  
	ret 
