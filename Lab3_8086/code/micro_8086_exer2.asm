EXIT 	MACRO				;macro exits back to DOS
	MOV AX,4C00H
	INT 21H
ENDM

PRINT	MACRO	CHAR		;macro to print a char
	PUSH DX
	PUSH AX
	MOV DL,CHAR
	MOV AH,2
	INT 21H
	POP AX
	POP DX
ENDM

READ	MACRO				;macro to read a char from keyboard
	MOV AH,8
	INT 21H
ENDM

PRINT_STRING MACRO STRING	;macro that prints a whole string
	PUSH DX
	PUSH AX
	LEA DX,STRING
	MOV AH,09H
	INT 21H
	POP AX
	POP DX
ENDM 



DATA_SEG SEGMENT
	MSG1 DB "GIVE DECIMAL DIGITS: ",'$'
	MSG2 DB "HEX= ",'$' 
	LINEFEED DB 0DH,0AH,'$'
DATA_SEG ENDS

STACK_SEG SEGMENT STACK
	DB 50 DUP(?)			;50 bytes for stack
STACK_SEG ENDS

CODE_SEG SEGMENT
	ASSUME CS:CODE_SEG,DS:DATA_SEG,SS:STACK_SEG 
	
PRINT_HEX PROC NEAR
    CMP DL,9
    JLE ADDR3
    ADD DL,37H
    JMP ADDR4
ADDR3:ADD DL,30H
ADDR4:PRINT DL
    RET
PRINT_HEX ENDP

MAIN PROC FAR
	MOV AX,DATA_SEG
	MOV DS,AX				;DS <- DATA_SEG
	MOV AX,DATA_SEG
	MOV SS,AX				;SS <- STACK_SEG
	JMP START


TERMINATE_CHECK_FIRST_4:  ;tsekarw efoson eimai stis 4 prwtes epanalhpseis na m er8ei h akolou8ia D15 opote kai termatizw. an den er8ei oi ari8moi pou isws dw8oun meta to D apo8hkeyontai kanonika san tous 4 prwtous
    READ 
    MOV AH,0
    CMP AL,'0'
    JNE CHECK
    PRINT AL
    SUB AL,48D
    CMP CX,4D
    JNE SKIP
    PRINT ','    
SKIP:
    PUSH AX 
    DEC CX 
    READ 
    MOV AH,0
    CMP AL,'6'
    JE TERMINATE
    JMP CHECK

TERMINATE_CHECK_GENERAL:
    READ
    MOV AH,0
    CMP AL,'0'
    JNE CHECK2
    PRINT AL
    SUB AL,48D              ;ftiakse ston AL ton teleytaio ari8mo pou diavases
    MOV BH,BL
    MOV BL,CH
    MOV CH,CL
    MOV CL,AL               ;kanw update gia na exw ta swsta 4 teleytaia noumera gia ton ypologismo mou
	READ
	MOV AH,0
	CMP AL,'6'
	JE TERMINATE
	JMP CHECK2


TERMINATE:
	EXIT
	
START:
	PRINT_STRING MSG1
	MOV CX,4D				;Arxikopoiisi metriti sto 4 (4 toulaxiston psifia pros anagnwsi)
	MOV DX,0D				;o DX tha exei ton arithmo pou diavazetai (arxikopoiisi 0)
    MOV BX,0D               ;tha mou xreiastei gia to swsimo twn arithmwn
    
READ_DEC:
	READ					;diavase apo to pliktrologio
	MOV AH,0				;o kwdikos vrisketai sto AL kai etsi vazw sto AH 0 
	
CHECK:
	CMP AL,'D'				;an diavases D checkare an prepei na termatiseis to programma
	JE TERMINATE_CHECK_FIRST_4
	CMP AL,'0'				;an diavases ascii xaraktira me kwdiko < '0' ksanadiavase (lathos xaraktiras)
	JL READ_DEC
	CMP AL,'9'				;an einai panw apo to '9' mh egkuro psifio, ksanadiavase
	JG READ_DEC             ;alliws synexise
	
ADDR1:
	PRINT AL				;tupwse to xaraktira pou diavases
	SUB AL,30H				;kai metetrepse ton ston antistoixo arithmo
    CMP CX,4D               ;afou diavasw ton prwto egkyro kai ton typwsw typwnw meta to ',' ka8ws se default mode 8a pairnw enan 4pshfio
	JL READY                ;epomenws ekei tha einai oi xiliades tou    
    PRINT ','
	               
READY:
    PUSH AX                 ;pusharw se ka8e loupa ta stoixeia tou AX gia na krathsw meta apo ta 4 pshfia to ka8e ena ksexwrista kai na kanw update
	LOOP READ_DEC           ;gia na diavasw toulaxiston 4 pshfia

RESTORE_VALUES:
    POP AX                  ;o AL exei thn timh tou 4ou pshfiou pou phra
    MOV CL,AL               ;o CL exei ton teleytaio ari8mo pou phra
    POP AX                  ;O AL exei thn timh tou 3ou pshfiou pou phra
    MOV CH,AL               ;o CH exei ton proteleytaio ari8mo apo tous 4 prwtous pou phra (ton 3o dld)	
	POP AX                  ;o AL exei thn timh tou 2ou pshfiou ek twn 4 prwtwn pou mou do8hke
	MOV BL,AL               ;o BL exei ton 2o ari8mo apo tous 4 prwtous pou mou do8hkan
	POP AX                  ;o AL exei thn timh tou 1ou pshfiou ek twn 4 prwtwn pou mou do8hke
	MOV BH,AL               ;o BH exei ton 1o ari8mo apo tous 4 prwtous pou mou do8hkan
	                        ;h diataksh ayth 8a parameinei
	                        ;dhladh o ari8mos pou 8a exw na typwsw sto telos otan path8ei enter 8a einai
	                        ;BH,BL,CH,CL
CONTINUE_READ:
    READ					;diavase apo to pliktrologio
	MOV AH,0
CHECK2:
	CMP AL,0DH              ;checkarw gia enter opote paw sthn eksodo
	JE ENTER_PRESSED		;o kwdikos vrisketai sto AL kai etsi vazw sto AH 0
	CMP AL,'D'				;an diavases D checkare gia termatismo
	JE TERMINATE_CHECK_GENERAL
	CMP AL,'0'				;an diavases ascii xaraktira me kwdiko < '0' ksanadiavase (lathos xaraktiras)
	JL CONTINUE_READ
	CMP AL,'9'				;an einai panw apo to 9  mh egkuro psifio,ksanadiavase
	JG CONTINUE_READ

UPDATE:
    PRINT AL
    SUB AL,48D              ;ftiakse ston AL ton teleytaio ari8mo pou diavases
    MOV BH,BL
    MOV BL,CH
    MOV CH,CL
    MOV CL,AL               ;kanw update gia na exw ta swsta 4 teleytaia noumera gia ton ypologismo mou
	JMP CONTINUE_READ

ENTER_PRESSED:
	PRINT_STRING LINEFEED
	PRINT_STRING MSG2  
	MOV AX,1000       ;BH periexei xiliades,BL periexei ekatontades,CH periexei dekades,CL periexei monades
	MOV DX,BX
	AND DX,0F00H       ;krataw mono ton BH me tis xiliades  !!!!!!!!1
	ROL DX,8
	MUL DX             ;vriskw poses xiliades exw
	MOV DX,AX          ;apothikeyw to apotelesma ston DX
	MOV AX,100         ;pros8etw tis BL ekatontades
	MUL BL             ;vriskw tis 100ades AX=100 * BL=ekatontades
	ADD AX,DX          ;prosthetw ton DX ston AX ara AX exei xiliades + ekatontades
	MOV DX,AX          ;o DX exei to apotelesma meta thn pros8esh xiliadwn kai ekatontadwn
	MOV AX,10         ;pros8etw tis CH dekades
	MOV BX,CX          ;o B twra de mou xreiazetai, xrhsimopoihsa to periexomeno tou 
	AND BX,0F00H       ;krataw ton CH ston B, dhladh tis dekades    !!!!!!!!!!
	ROL BX,8
	MUL BL 
	ADD AX,DX          ;prosthetw tis ekatontades kai tis xiliades ston AX pou twra periexei tis 10ades
	AND CX,00FFH       ;krataw ton CL pou periexei tis monades     
	ADD AX,CX          ;pros8etw tis CL monades   o AX exei twra to apotelesma pou prepei na typwsw
	MOV BX,AX          ;twra o BX exei ton arithmo mou se dyadikh morfh 
	
	MOV CX,4
PRINT_LOOP:
    ROL BX,4
    MOV DX,BX
    AND DX,000FH
    CALL PRINT_HEX
    LOOP PRINT_LOOP
    PRINT_STRING LINEFEED
    JMP START

MAIN ENDP

CODE_SEG ENDS
	END MAIN