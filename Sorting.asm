JMP START                                                     

SUITABLE_NUMBER_MSG db 10, 13, "Please Enter a suitable number in range [1-25]: $"                 
ENTER_NUMBER_OF_ELEMENTS_MSG db 10, 13, "Please enter the number of elements in the array to be sorted or press 0 to terminate: $"
ENTER_ELEMENTS_MSG db 10, 13, "Please enter elements of the array to be sorted: $"                                                                                 
SROTING_TYPE_MSG db 10, 13, "Enter a for ascending order or d for descending order: $"                                                                                 
SORTED_MSG db 10, 13, "The sorted array is: $"


ARRAY_LENGTH DB ?
ARRAY_INFO DB 3,?,3  dup(' ')   
INPUT_HANDLER DB 10, ?, 10 dup(' ')
ELEMENTS DB 10, ?, 10 dup(' ')   

BUFFER db 3 ,?,3  dup(' ')   ;defning a BUFFER to take input in the BUFFER will take no more than 2 chars

flag db 0
check  db 0       

START:
    LEA DX, ENTER_NUMBER_OF_ELEMENTS_MSG 
    MOV AH , 09h     
    INT 21H       
                    
    JMP GET_ARRAY_LENGHT                

START_WITH_RANGE_INFO:
    MOV AH,2
    MOV dl ,10
    INT 21H     ;Printing a new line
    MOV dl,13
    INT 21H

    MOV AH , 0
    MOV AL , 2h
    INT 10h
    LEA dx, SUITABLE_NUMBER_MSG  ; PrINTing the warning message
    MOV AH, 09h
    INT 21H


GET_ARRAY_LENGHT:
    LEA DX, ARRAY_INFO 
    MOV  AH, 0AH
    INT  21H
    
    MOV BL, ARRAY_INFO[1]        ; storing the size of the buffer in bl

    CMP BL ,1         ;checking if it is one digit or not
    JA TWO_DIGITS_ARRAY_LENGTH
    JE ONE_DIGITS_ARRAY_LENGTH
    
    ONE_DIGITS_ARRAY_LENGTH:
        MOV AL, ARRAY_INFO[2]                       ;if it is only one digit
        sub AL, 48                                 ;convert from ascci to digit
        jmp GUARD_AGAINEST_WRONG_NUMBER
    
    TWO_DIGITS_ARRAY_LENGTH:
        MOV AL, 10
        MOV AH, ARRAY_INFO[2]                          ;storing the first digit in ah
        sub AH, 48
        mul AH                                    ;Changing from ascii to digit
    
        MOV BL, ARRAY_INFO[3]                         ;Getting the enterd number in ASCII number form
        sub BL, 48                                 ;Changing from ascii to digit
        ADD AL, BL                                 ; now al hold the number from the user
    
    GUARD_AGAINEST_WRONG_NUMBER:
        CMP AL, 0                                ; Checking if the input is Zero if so end the programe
        JE END
        CMP AL ,25                                 ;if input [0-25] ? continue : display the warning massage
        JA WRONG_ARRAY_LENGTH
    
    ; STORE ARRAY LENGTH TO CX AS A COUNTER
    MOV ARRAY_LENGTH, AL                
    MOV CX, 0   
    MOV CL, ARRAY_LENGTH

    
    JMP ACCEPT_ARRAY_ELEMENTS
       
MOV SI, 1
ACCEPT_ARRAY_ELEMENTS:
    LEA DX, ENTER_ELEMENTS_MSG 
    MOV AH , 09h     
    INT 21H
    
    JMP STORE_USER_INPUT


STORE_USER_INPUT:
    ;Check if the elements are stored 
    CMP CX, 0
    JE SORT
    
    MOV flag, 0     
    LEA DX, INPUT_HANDLER
    MOV AH, 0AH
    INT 21H
    
    MOV BL, INPUT_HANDLER[1]                         ; storing the size of the BUFFER in bl

    CMP Bl, 1                                 ;checking if it is one digit or not
    JA SEVERAL_DIGITS_ENTERED
    JE ONE_DIGIT_ENTERED

ONE_DIGIT_ENTERED:
    MOV AL, INPUT_HANDLER[2]                       ;if it is only one digit
    SUB AL, 48                                 ;convert from ascci to digit
    JMP GUARD_AGAINEST_WRONG_NUMBERS

SEVERAL_DIGITS_ENTERED:
    MOV AL, 10
    MOV AH, INPUT_HANDLER[2]                          ;storing the first digit in ah
    sub AH, 48
    mul AH                                    ;Changing from ascii to digit
    
    MOV BL, INPUT_HANDLER[3]                         ;Getting the enterd number in ASCII number form
    sub BL, 48                                 ;Changing from ascii to digit
    ADD AL, BL 
    
GUARD_AGAINEST_WRONG_NUMBERS:
    CMP AL, 0                                ; Checking if the input is Zero if so end the programe
    JE END
    CMP AL, 25                                 ;if input [0-25] ? continue : display the warning massage
    JA START_WITH_RANGE_INFO

STORE_NUMBER_TO_ELEMENTS_ARRAY:
    MOV ELEMENTS[SI] , AL
    MOV BX, 0      
    MOV DX, 0
	MOV dl, offset ELEMENTS[SI]
	

DEC CX
INC SI
JMP STORE_USER_INPUT   


SORT:
    MOV CX, 0
    MOV CL, ARRAY_LENGTH
    MOV SI, 00
    SUB CX, 1
    
    
    ASK_FOR_SORTING_TYPE:
        LEA DX, SROTING_TYPE_MSG
        MOV AH, 09H
        INT 21H    
        MOV AH, 01H
        INT 21H
        CMP Al, 'a'
        JE SORT_ASC
        CMP Al, 'b'
        JE SORT_DESC          

    
    SORT_ASC:
        CMP CX, SI          
        JZ CYCLE_ASC
        MOV AL, ELEMENTS[SI]  
        MOV BL, ELEMENTS[SI + 1]  
        CMP AL, BL           
        JG SWAP_ASC
        ADD SI, 1           
        JMP SORT_ASC

        SWAP_ASC:
            MOV ELEMENTS[SI + 1], AL
            MOV ELEMENTS[SI], BL
            ADD SI, 1
            JMP SORT_ASC
        CYCLE_ASC:                   
            MOV SI, 0            
            SUB CX, 1            
            CMP CX, 0
            JNZ SORT_ASC
     JMP ARRAY_SORTED
            
     SORT_DESC:
        CMP CX, SI          
        JZ CYCLE_DESC
        MOV AL, ELEMENTS[SI]  
        MOV BL, ELEMENTS[SI + 1]  
        CMP AL, BL           
        JS SWAP_DESC
        ADD SI, 1           
        JMP SORT_DESC

        SWAP_DESC:
            MOV ELEMENTS[SI + 1], AL
            MOV ELEMENTS[SI], BL
            ADD SI, 1
            JMP SORT_DESC
        CYCLE_DESC:                   
            MOV SI, 0            
            SUB CX, 1            
            CMP CX, 0
            JNZ SORT_DESC
    
            
    
    ARRAY_SORTED:
        LEA dx, SORTED_MSG ;Print "Sorting"
        MOV AH, 09H
        INT 21H
    
    MOV SI, 0
    MOV BX, 0           
    MOV DX, 0
    MOV BL, ARRAY_LENGTH
    
    PRINT_SORTED_ARRAY:
        MOV DL, ARRAY_LENGTH
        CMP SI, DX 
        JE TASK_FINISHED
        MOV AX, 0
        MOV AL, ELEMENTS[SI]
        
        CMP AL, 9
        JA PRINIT_MULTI_DIGIT      ;Checking if the number is 1-digit or multi-digit
        JMP PRINT_ONE_DIGIT
        
       
        PRINT_ONE_DIGIT:      
            MOV DL, ELEMENTS[SI]
            ADD DX, 48
            MOV AH, 02H
            INT 21H
            MOV Dl, 44
            INT 21H
            JMP HANDLE_NEXT_ELEMENT
        
        MOV AL, ELEMENTS[SI]
            
        PRINIT_MULTI_DIGIT:
            PUSH CX                                   ;save the value of the main loop by pushing it in the stack & clear the counter
            MOV BX, 10
            MOV CX,0
        
            NEXT:
            MOV DX, 0
            DIV BX                                      ; ax = ax / bx >> dx = reminder
            ADD DL,48                                   ; converting the firist digit to a char again
        
            PUSH DX                                   ; pushing digits in the stack to print them later
            INC CX                                    ;Increamenting the counter to count the number of digits to know when to stop when popinng
            CMP AX, 0                                  ; if ax=0 means the all digits are stored
            JE PRINT_SEPARATED_DIGIT
            JMP NEXT
        
        PRINT_SEPARATED_DIGIT:
            POP DX
            MOV AH, 02H                                ;Poping cx-digits and Printing it using int21h/2h
            INT 21H
            LOOP PRINT_SEPARATED_DIGIT     ; loop works while (cx--)
            POP CX                                    ; all digits are printed now cx holds the main counter of the series
            JMP comma
        
        comma:                                    ;printing ',' between digits as 44 is the ascci for the ','
            CMP CX, 1
            je PRINT_SORTED_ARRAY
            MOV Dl, 44
            INT 21H

            
            
        HANDLE_NEXT_ELEMENT:
            INC SI
            JMP PRINT_SORTED_ARRAY
        
        
        
    TASK_FINISHED:
    JMP START_AGAIN    

WRONG_ARRAY_LENGTH:
    MOV AH,2
    MOV dl ,10
    INT 21H                                   ;PrINTing a new line
    MOV dl,13
    INT 21H

    MOV AH , 0
    MOV  al , 2h
    INT 10h
    LEA dx , SUITABLE_NUMBER_MSG                   ;prINTing the warning message
    MOV AH , 09h
    INT 21H
    JMP GET_ARRAY_LENGHT


START_AGAIN:
    JMP START
    
END:
    hlt
