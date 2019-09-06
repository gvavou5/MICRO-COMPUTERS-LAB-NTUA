include 'emu8086.inc' 
org 100h
.data
new_line DB 0Dh,0Ah,"$"
echo_mode DB "CHOOSE ECHO MODE: <1> FOR ECHO ON OR <0> FOR ECHO OFF$"
;1 για ΟΝ δηλαδή οι χαρακτήρες τυπώνονται και το
;αντίθετο
br DB 0Ah,0Dh,"CHOOSE BAUD RATE: <1> FOR 300 <2> FOR 600 <3> FOR 1200 <4> FOR 2400 <5> FOR 4800 OR <6> FOR 9600 $"
;ταχύτητα επικοινωνίας
loc DB "LOCAL $" 
rem DB "REMOTE $"
divline DB 08,80 DUP (0C4h),"$" 
em DB ? ;echo mode
tmp DB ?
linloc DB 00h	
colloc DB 0Bh	
linrem DB 0Dh	
colrem DB 0Bh	;μεταβλητή στήλης απομακρυσμένης οθόνης

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
    cmp AL,08h	;αν είναι το BACKSPACE τότε πάμε στη macro
                ;BACKSP
    
    jne NEXT4
    CALL BACKSP

NEXT4: 
    mov ah,0Eh
    int 10h	;αλλιώς τον τυπώνουμε 
    mov AH,03H
    mov BH,00H 
    int 10h
    cmp DL,4Fh	;αν δεν έχουμε φτάσει στο τέλος της γραμμής,
                ;ενημερώνουμε τις μεταβλητές linrem,colrem jne UPDRC	;σχετικά με τη νέα θέση του δρομέα
    jne UPDRC    
    
REM_ENTER:
    inc	DH	;αν έρθει ENTER ή αν φτάσουμε στο τέλος της
    		;γραμμής τότε αυξάνουμε το μετρητή γραμμών
    cmp	DH,19h	;της απομακρυσμένης οθόνης και ελέγχουμε αν
    		;έχουμε φτάσει στην τελευταία γραμμή
    jne	NOSCROLL1	;αν όχι, τότε δεν κάνουμε scroll
    mov	AH,06h	;αλλώς θέτουμε τις κατάλληλες παραμέτρους στη
    		;διακοπή INT10/06 για να κάνουμε το scroll
    mov	AL,01h	
    mov	CH,0Dh	
    mov	CL,0Bh	
    mov	DH,18h	
    mov	DL,4Fh	
    mov	BH,07h	
    int	10h	
    mov	linrem,18h	;είμαστε πλέον στην τελευταία γραμμή της
    		;απομακρυσμένης οθόνης (REMOTE) και θα
    		;μείνουμε εκεί
    mov	colrem,0Bh	;ενημερώνουμε και τη μεταβλητή στήλης ότι
    		;είμαστε στην αρχή (ορίσαμε ως αρχή τη στήλη
    		;0Bh)
    jmp	CHK	;ελέγχουμε την τοπική είσοδο
 
UPDRC:

    cmp DL,0Bh	;αν είμαστε πιο πίσω από αυτό που ορίσαμε για
    ;αρχική στήλη, πάμε στο 0Bh
    
    jge NEXT5 
    mov DL,0Bh

NEXT5:
    mov linrem,DH	;ενημερώνουμε τις μεταβλητές της

    mov colrem,DL
                    ;απομακρυσμένης οθόνης για τη νέα θέση του
                    ;δρομέα

    jmp CHK	;ελέγχουμε την τοπική είσοδο

NOSCROLL1:
    mov linrem,DH	;ενημερώνουμε τη μεταβλητή γραμμής και
                    ;αρχικοποιούμε τη μεταβλητή στήλης
    mov colrem,0Bh


CHK:

    mov AH,06h	;ελέγχουμε αν έχει πατηθεί κάποιο πλήκτρο,
    ;αλλά δεν κάνουμε wait για να μην
    mov DL,0FFh	;κολλήσει το πρόγραμμα εκεί αν δεν πατηθεί
    ;κάποιο πλήκτρο
    
    int 21h
    jz RX	;αν δεν έχει πατηθεί πλήκτρο επιστροφή πίσω
    ;για ανάγνωση δεδομένων
    cmp AL,1Bh	;αλλιώς ελέγχουμε αν το πλήκτρο που πατήθηκε
    ;είναι esc
    je QUIT	;που έχουμε θέσει ως συνδυασμό εξόδου DOS 
    mov BL,em	;αν όχι, τότε φέρνουμε στον BL το echo mode
    cmp BL,30h	;αν είναι 0 τότε στέλνουμε το χαρακτήρα χωρίς 
    je TX	;να τον τυπώσουμε
    mov tmp,AL	;αλλιώς αποθηκεύουμε την τιμή που λάβαμε στο
    ;tmp
    mov AH,02h	;βάζουμε το δρομέα στην κατάλληλη θέση για να 
    mov DH,linloc	; τυπώσουμε στην τοπική οθόνη (LOCAL)
    mov DL,colloc 
    mov BH,00h 
    int 10h
    cmp AL,0Dh	;ελέγχουμε αν ο προς εκτύπωση χαρακτήρας
    ;είναι το ENTER
    je LOC_ENTER	;αν είναι τότε μεταφορά LOC_ENTER
    cmp AL,08h	;αλλιώς έλεγχουμε αν είναι το BACKSPACE 
    jne NEXT3	;αν είναι μεταφορά στη macro BACKSP 
    CALL BACKSP

NEXT3:
    mov ah,0Eh
    int 10h	;αλλιώς τον τυπώνουμε 
    mov AH,03H
    mov BH,00H 
    int 10h
    cmp DL,4Fh	;αν δεν έχουμε φτάσει στο τέλος γραμμής,
    ;ενημερώνουμε τις μεταβλητές linloc,colloc 
    jne UPDLC	;σχετικά με τη νέα θέση του δρομέα
    
LOC_ENTER:
    inc DH	;αν έρθει ENTER ή αν φτάσουμε στο τέλος της
    ;γραμμής τότε αυξάνουμε το μετρητή γραμμών 
    cmp DH,0Ch	;της τοπικής οθόνης και ελέγχουμε αν έχουμε
    ;φτάσει στην τελευταία γραμμή 
    jne NOSCROLL2	;αν όχι, τότε δεν κάνουμε scroll
    mov AH,06h	;αλλιώς θέτουμε τις κατάλληλες παραμέτρους
    ;στη διακοπή INT10/06 για να κάνουμε το
    mov AL,01h	;SCROLL
    mov CH,00h 
    mov CL,0Bh 
    mov DH,0Bh 
    mov DL,4Fh
    mov BH,07h 
    int 10h
    mov linloc,0Bh	;είμαστε πλέον στην τελευταία γραμμή της
    ;τοπικής οθόνης (LOCAL) και παραμένουμε εκεί 
    mov colloc,0Bh	;ενημερώνουμε τη μεταβλητή στήλης ότι είμαστε
    ;στην αρχή (έχουμε ορίσει ως αρχή τη στήλη
    ;0Bh)
    jmp NEXT	;επαναφέρουμε τον χαρακτήρα στον AL για να
    ;τον στείλουμε
    

UPDLC:
    cmp DL,0Bh	;αν είμαστε πιο πίσω από αυτό που έχουμε
    ;ορίσει ως αρχική στήλη, πάμε στο 0Bh
    
    jge NEXT2 
    mov DL,0Bh
NEXT2: mov linloc,DH	;και ενημερώνουμε τις μεταβλητές της
    ;τοπικής οθόνης για τη νέα θέση του δρομέα
    mov colloc,DL
    jmp NEXT	;επαναφέρουμε το χαρακτήρα σον AL για να τον στείλουμε
    
NOSCROLL2:
    mov linloc,DH	;ενημερώνουμε τη μεταβλητή γραμμής και
    ;αρχικοποιούμε τη μεταβλητή στήλης
    mov colloc,0Bh


NEXT:
    mov AL,tmp	;επαναφέρουμε το χαρακτήρα σον AL για να τον
;στείλουμε



TX:
    call TXCH_RS232	;καλούμε τη ρουτίνα που στέλνει το χαρακτήρα
;που πληκτρολογήσαμε
    jmp RX	;ελέγχουμε αν έχει έρθει άλλος χαρακτήρας


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
    mov AH,02h	;ορίζουμε διακοπή που τοποθετεί το δρομέα στη συγκεκριμένη θέση

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