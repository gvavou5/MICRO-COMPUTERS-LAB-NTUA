include 'emu8086.inc' 
org 100h
.data
new_line DB 0Dh,0Ah,"$"
echo_mode DB "CHOOSE ECHO MODE: <1> FOR ECHO ON OR <0> FOR ECHO OFF$"
;1 ��� �� ������ �� ���������� ���������� ��� ��
;��������
br DB 0Ah,0Dh,"CHOOSE BAUD RATE: <1> FOR 300 <2> FOR 600 <3> FOR 1200 <4> FOR 2400 <5> FOR 4800 OR <6> FOR 9600 $"
;�������� ������������
loc DB "LOCAL $" 
rem DB "REMOTE $"
divline DB 08,80 DUP (0C4h),"$" 
em DB ? ;echo mode
tmp DB ?
linloc DB 00h	
colloc DB 0Bh	
linrem DB 0Dh	
colrem DB 0Bh	;��������� ������ �������������� ������

.code

main PROC FAR

PRINT_STR echo_mode 
PRINT_STR new_line 
ECHO_MODE1:
    MOV AH,08h	
    int 21h
    CMP AL,30h	
    JE Valid1
    CMP AL,31h	
    JNE ECHO_MODE1

Valid1:
    mov em,AL 
    PRINT_STR br
    PRINT_STR new_line

BAUD_RATE1:
    MOV AH,08h	
    int 21h
    CMP AL,31h	
    Jl BAUD_RATE1
    CMP AL,36h
    JLE  Valid2 
    JMP BAUD_RATE1
    
Valid2:
    sub AL,30h 
    and AL,03h
    call OPEN_RS232	
    mov AH,00h 
    mov AL,2
    int 10h	
    mov AH,02h	
    mov DH,00h	
    PRINT_STR loc 
    mov AH,02h 
    mov DH,0Ch 
    mov DL,01h 
    mov BH,00h 
    int 10h
    PRINT_STR divline 
    
    mov AH,02h 
    mov DH,0Dh 
    mov DL,01h 
    mov BH,00h 
    int 10h
    PRINT_STR rem     

RX:
    call RXCH_RS232	
    cmp AL,0h	
    je CHK
    mov AH,02h	
                
                
    mov DH,linrem	 
    mov DL,colrem
    mov BH,00h 
    int 10h
    cmp AL,0Dh	
    je REM_ENTER
    cmp AL,08h	;�� ����� �� BACKSPACE ���� ���� ��� macro
                ;BACKSP
    
    jne NEXT4
    CALL BACKSP

NEXT4: 
    mov ah,0Eh
    int 10h	;������ ��� ��������� 
    mov AH,03H
    mov BH,00H 
    int 10h
    cmp DL,4Fh	;�� ��� ������ ������ ��� ����� ��� �������,
                ;������������ ��� ���������� linrem,colrem jne UPDRC	;������� �� �� ��� ���� ��� ������
    jne UPDRC    
    
REM_ENTER:
    inc	DH	;�� ����� ENTER � �� �������� ��� ����� ���
    		;������� ���� ��������� �� ������� �������
    cmp	DH,19h	;��� �������������� ������ ��� ��������� ��
    		;������ ������ ���� ��������� ������
    jne	NOSCROLL1	;�� ���, ���� ��� ������� scroll
    mov	AH,06h	;����� ������� ��� ���������� ����������� ���
    		;������� INT10/06 ��� �� ������� �� scroll
    mov	AL,01h	
    mov	CH,0Dh	
    mov	CL,0Bh	
    mov	DH,18h	
    mov	DL,4Fh	
    mov	BH,07h	
    int	10h	
    mov	linrem,18h	;������� ����� ���� ��������� ������ ���
    		;�������������� ������ (REMOTE) ��� ��
    		;�������� ����
    mov	colrem,0Bh	;������������ ��� �� ��������� ������ ���
    		;������� ���� ���� (������� �� ���� �� �����
    		;0Bh)
    jmp	CHK	;��������� ��� ������ ������
 
UPDRC:

    cmp DL,0Bh	;�� ������� ��� ���� ��� ���� ��� ������� ���
    ;������ �����, ���� ��� 0Bh
    
    jge NEXT5 
    mov DL,0Bh

NEXT5:
    mov linrem,DH	;������������ ��� ���������� ���

    mov colrem,DL
                    ;�������������� ������ ��� �� ��� ���� ���
                    ;������

    jmp CHK	;��������� ��� ������ ������

NOSCROLL1:
    mov linrem,DH	;������������ �� ��������� ������� ���
                    ;������������� �� ��������� ������
    mov colrem,0Bh


CHK:

    mov AH,06h	;��������� �� ���� ������� ������ �������,
    ;���� ��� ������� wait ��� �� ���
    mov DL,0FFh	;�������� �� ��������� ���� �� ��� �������
    ;������ �������
    
    int 21h
    jz RX	;�� ��� ���� ������� ������� ��������� ����
    ;��� �������� ���������
    cmp AL,1Bh	;������ ��������� �� �� ������� ��� ��������
    ;����� esc
    je QUIT	;��� ������ ����� �� ��������� ������ DOS 
    mov BL,em	;�� ���, ���� �������� ���� BL �� echo mode
    cmp BL,30h	;�� ����� 0 ���� ��������� �� ��������� ����� 
    je TX	;�� ��� ���������
    mov tmp,AL	;������ ������������ ��� ���� ��� ������ ���
    ;tmp
    mov AH,02h	;������� �� ������ ���� ��������� ���� ��� �� 
    mov DH,linloc	; ��������� ���� ������ ����� (LOCAL)
    mov DL,colloc 
    mov BH,00h 
    int 10h
    cmp AL,0Dh	;��������� �� � ���� �������� ����������
    ;����� �� ENTER
    je LOC_ENTER	;�� ����� ���� �������� LOC_ENTER
    cmp AL,08h	;������ ��������� �� ����� �� BACKSPACE 
    jne NEXT3	;�� ����� �������� ��� macro BACKSP 
    CALL BACKSP

NEXT3:
    mov ah,0Eh
    int 10h	;������ ��� ��������� 
    mov AH,03H
    mov BH,00H 
    int 10h
    cmp DL,4Fh	;�� ��� ������ ������ ��� ����� �������,
    ;������������ ��� ���������� linloc,colloc 
    jne UPDLC	;������� �� �� ��� ���� ��� ������
    
LOC_ENTER:
    inc DH	;�� ����� ENTER � �� �������� ��� ����� ���
    ;������� ���� ��������� �� ������� ������� 
    cmp DH,0Ch	;��� ������� ������ ��� ��������� �� ������
    ;������ ���� ��������� ������ 
    jne NOSCROLL2	;�� ���, ���� ��� ������� scroll
    mov AH,06h	;������ ������� ��� ���������� �����������
    ;��� ������� INT10/06 ��� �� ������� ��
    mov AL,01h	;SCROLL
    mov CH,00h 
    mov CL,0Bh 
    mov DH,0Bh 
    mov DL,4Fh
    mov BH,07h 
    int 10h
    mov linloc,0Bh	;������� ����� ���� ��������� ������ ���
    ;������� ������ (LOCAL) ��� ����������� ���� 
    mov colloc,0Bh	;������������ �� ��������� ������ ��� �������
    ;���� ���� (������ ������ �� ���� �� �����
    ;0Bh)
    jmp NEXT	;������������ ��� ��������� ���� AL ��� ��
    ;��� ���������
    

UPDLC:
    cmp DL,0Bh	;�� ������� ��� ���� ��� ���� ��� ������
    ;������ �� ������ �����, ���� ��� 0Bh
    
    jge NEXT2 
    mov DL,0Bh
NEXT2: mov linloc,DH	;��� ������������ ��� ���������� ���
    ;������� ������ ��� �� ��� ���� ��� ������
    mov colloc,DL
    jmp NEXT	;������������ �� ��������� ��� AL ��� �� ��� ���������
    
NOSCROLL2:
    mov linloc,DH	;������������ �� ��������� ������� ���
    ;������������� �� ��������� ������
    mov colloc,0Bh


NEXT:
    mov AL,tmp	;������������ �� ��������� ��� AL ��� �� ���
;���������



TX:
    call TXCH_RS232	;������� �� ������� ��� ������� �� ���������
;��� ���������������
    jmp RX	;��������� �� ���� ����� ����� ����������


QUIT:
    MOV AX,4C00h ; direct exit to DOS
    INT 21H

main ENDP



OPEN_RS232 PROC NEAR 
    JMP START
    BAUD_RATE LABEL WORD 
    DW 1047
    DW 768
    DW 384
    DW 192
    DW 96
    DW 48
    DW 24
    DW 12 
START:
    STI
    MOV AH,AL 
    MOV DX,03FBH
    MOV AL,80H 
    OUT DX,AL 
    MOV DL,AH 
    MOV CL,4
    
    ROL DL,CL 
    AND DX,0EH
    MOV DI,OFFSET BAUD_RATE 
    ADD DI,DX
    MOV DX,03F9H
    MOV AL,CS:[DI]+1 
    OUT DX,AL
    MOV DX,03F8H 
    MOV AL,CS:[DI] 
    OUT DX,AL
    MOV DX,03FBH 
    MOV AL,AH 
    AND AL,01FH 
    OUT DX,AL 
    MOV DX,03F9H 
    MOV AL,0H 
    OUT DX,AL 
    RET
OPEN_RS232 ENDP

RXCH_RS232 PROC NEAR 
    MOV DX,3FDh
    IN AL,DX 
    TEST AL,1 
    JZ NOTHING 
    SUB DX,5 
    IN AL,DX 
    JMP EX2

NOTHING:
    MOV AL,0
EX2:
    RET

RXCH_RS232 ENDP


TXCH_RS232 PROC NEAR 
    PUSH AX
    MOV DX,03FDh

TXCH_RS232_2:
    IN AL,DX 
    TEST AL,020h
    JZ TXCH_RS232_2 
    SUB DX,5
    POP AX 
    OUT DX,AL 
    RET
TXCH_RS232 ENDP 

BACKSP PROC NEAR
    mov AH,02h	;�������� ������� ��� ��������� �� ������ ��� ������������ ����

    dec DL 
    int 10h
    CALL pthis 
    DB ' ', 0
    ret

BACKSP ENDP


PRINT_STR MACRO STRING 
    PUSH DX
    PUSH AX
    MOV DX,OFFSET STRING 
    MOV AH,9
    INT 21H 
    POP AX 
    POP DX
    ENDM



DEFINE_PTHIS 
END