PRINT MACRO CHAR    ; makroentolh ektypwshs xarakthra 
PUSH DX
PUSH AX
MOV DL,CHAR
MOV AH,2
INT 21H
POP AX
POP DX
ENDM 

READ MACRO ;makroentolh me thn opoia diabazoyme ena xarakthra apo to plhktrologio
MOV AH,8
INT 21H
ENDM 

PRINT_STR MACRO STRING
MOV DX,OFFSET STRING
MOV AH,9
INT 21H
ENDM 

EXIT MACRO ;macro exits back to DOS
MOV AX,4C00H
INT 21H
ENDM    

DATA_SEG SEGMENT
NEW_LINE DB 0AH,0DH,'$'
MSG1 DB 'GIVE AN  8-BIT BINARY NUMBER:$'
MSG2 DB 'DECIMAL:$'
DATA_SEG ENDS
CODE_SEG SEGMENT
ASSUME CS:CODE_SEG,DS:DATA_SEG 

MAIN PROC FAR
MOV AX,DATA_SEG
MOV DS,AX 

START:
MOV DX,0          ;mhdenizw ton dx opou 8a exei telika ton BCD ari8mo
MOV CX,8          ;metrhths pshfiwn 
PUSH DX
PRINT_STR MSG1
POP DX 

IGNORE:
READ
;AND AH,01H
CMP AL,'Q'        ;an dwsame to 'q'na termatistei to programma
JE QUIT
CMP AL,30H        ; an einai to '0' to dexomai 
JL IGNORE
CMP AL,31H        ; an einai to '1' to dexomai 
JG IGNORE
JMP ADDR1

ADDR1:
PUSH DX
PRINT AL          ;typwnw to prwto bit pou diabasa apo to plhktrologio 
POP DX
SUB AL,30H         ;metatroph tou ascii code se duadiko ari8mo 
PUSH CX
SHL DX,1             ;ton kanw olis8hsh giati arxizw na diabazw apo to msb bit 
ADD DX,AX
POP CX
LOOP IGNORE          ;diabazw ta 8 bit mexri o cx na ginei 0
PUSH DX
PRINT_STR NEW_LINE
PRINT_STR MSG2
POP DX
;MOV CX,DX

CONT:
;MOV DX,CX
MOV AL,0000H ;EKATONTADES
MOV BL,0000H ;DEKADES
             ;DX MONADES
CHECK1:
CMP DL,64H ; sygkrish me to 100

JAE PLUS_100
CHECK2:
CMP DL,0AH ; sygkrish me to 10
JAE PLUS_10 

PRINT_OUTPUT:
ADD AL,30H  ; metatroph dyadiko se ascii code 
PRINT AL
ADD BL,30H  ; metatroph bin se ascii code
PRINT BL
ADD DL,30H  ; metatroph bin se ascii code
PRINT DL
PRINT_STR NEW_LINE
JMP START
QUIT:
EXIT
MAIN ENDP  

PLUS_10:
INC BL
SUB DL,0AH
JMP CHECK2
PLUS_100:
INC AL
SUB DL,64H
JMP CHECK1
CODE_SEG ENDS
END MAIN
