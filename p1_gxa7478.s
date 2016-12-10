/******************************************************************************
* @file p1_1000717
* @simple calculator calculating max/sub/add/mult
* Code was obtained and modifed from Christopher D. McMurrough github(cse2312)

******************************************************************************/

 
.global main
.func main
   
main:


    BL  _scanf             @ branch to scanf procedure with return
    MOV R4, R0        	   @ moves return value to a restorable resgister
    BL _getchar		   @ branch to getchar procedure with return
    MOV R5, R0		   @ moves return value to a restorable resgister
    BL  _scanf		   @ branch to scanf procedure with return
    MOV R6, R0             @ moves return value to a restorable resgister
    BL _compare            @ branches to a compare function
    BL  _printf            @ Branches off to print result
    B main                 @loops up to beginning of main

    BL  _scanf             @ branch to scanf procedure with return
    MOV R4, R0            
    BL _getchar
    MOV R5, R0
    BL  _scanf
    MOV R6, R0
    BL _compare
    @MOV R7, R0 
    BL  _printf            
    B main


_getchar:
    MOV R7, #3              @ write syscall, 3
    MOV R0, #0              @ input stream from monitor, 0
    MOV R2, #1              @ read a single character
    LDR R1, =read_char      @ store the character in data memory
    SWI 0                   @ execute the system call
    LDR R0, [R1]            @ move the character to the return register
    AND R0, #0xFF           @ mask out all but the lowest 8 bits
    MOV PC, LR              @ return

_printf:
    MOV R4, LR              @ store LR since printf call overwrites
    LDR R0, =printf_str     @ R0 contains formatted string address
    MOV R1, R1              @ R1 contains printf argument (redundant line)
    BL printf               @ call printf
    MOV PC, R4              @ return
    
_scanf:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return

_compare:

    CMP R5, #'+'            @compares character to operation code char '+'
    BEQ _add                @ branches to function to execute and return 
    CMP R5, #'-'            @compares character to operation code char '-'
    BEQ _sub		    @ branches to function to execute and return 
    CMP R5, #'*'            @compares character to operation code char '*'
    BEQ _mult               @ branches to function to execute and return 
    CMP R5, #'M'            @compares character to operation code char 'M'
    BEQ _max    	    @ branches to function to execute and return              
    MOV PC, LR              @returns back to main 

_add:        
    ADD R1, R4, R6          @ adds restorable registers
    MOV PC, LR              @return

_sub:
    SUB R1, R4, R6	    @ subtracts restorable registers
    MOV PC, LR              @return

_mult:
    MUL R1, R4, R6          @ multiplies restorable registers
    MOV PC, LR	            @return

_max:
    CMP R4, R6              @ compares restorable registers to see which one is greater
    MOVGE R1, R4            @ if first restorable register is greater move to R1
    MOVLT R1, R6            @ if second restorable register is greater move to R1
    MOV PC, LR              @return

    CMP R5, #'+'
    BEQ _add
    CMP R5, #'-'
    BEQ _sub
    CMP R5, #'*'
    BEQ _mult
    CMP R5, #'M'
    BEQ _max
    MOV PC, LR

_add:
    ADD R1, R4, R6
    MOV PC, LR

_sub:
    SUB R1, R4, R6
    MOV PC, LR

_mult:
    MUL R1, R4, R6
    MOV PC, LR

_max:
    CMP R4, R6
    MOVGE R1, R4
    MOVLT R1, R6
    MOV PC, LR

.data
format_str:     .asciz      "%d"
read_char:      .ascii      " "
printf_str:     .asciz      "%d\n"
