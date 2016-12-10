/******************************************************************************
* @file float_scanf.s
* @brief example of obtaining a floating point value using scanf
*
* Obtains a floating point value using scanf. The single precision number is
* stored in memory by scanf and then returned in R0. R0 is then moved to S0,
* where it is converted to double precision in D1. D1 is then split into R1 and
* R2 for compatability with printf.
*
* @author Christopher D. McMurrough
******************************************************************************/
 
.global main
.func main
   
main:

    MOV R1, #1
    VMOV S1, R1
    VCVT.F32.U32 S1, S1
    B _main

_main:

    BL  _scanf              @ branch to scanf procedure with return
    VMOV S0, R0             @ move return value R0 to FPU register S0

    VCVT.F32.U32 S0, S0 	

    BL _getchar
    MOV R5, R0
    BL _compare

    BL  _printf             @ branch to print procedure with return
    B   _main
 
_getchar:

    PUSH {LR}
    MOV R7, #3              @ write syscall, 3
    MOV R0, #0              @ input stream from monitor, 0
    MOV R2, #1              @ read a single character
    LDR R1, =read_char      @ store the character in data memory
    SWI 0                   @ execute the system call
    LDR R0, [R1]            @ move the character to the return register
    AND R0, #0xFF           @ mask out all but the lowest 8 bits
    POP {PC}

_compare:

    PUSH {LR}
    CMP R5, #'a'            @compares character to operation code char '+'
    BEQ _abs                @ branches to function to execute and return 
    CMP R5, #'s'            @compares character to operation code char '-'
    BEQ _sqroot		    @ branches to function to execute and return 
    CMP R5, #'p'            @compares character to operation code char '*'
    BEQ _pow                @ branches to function to execute and return 
    CMP R5, #'i'            @compares character to operation code char 'M'
    BEQ _inverse    	    @ branches to function to execute and return              
    POP {PC}

_abs:

    PUSH {LR}
    VABS.F32 S2,S0
    VCVT.F64.F32 D4,S2 
    VMOV R1, R2, D4
    POP {PC}

_sqroot:

    PUSH {LR}
    VSQRT.F32 S2,S0
    VCVT.F64.F32 D4,S2
    VMOV R1, R2, D4
    POP {PC}

_pow:
  
    PUSH {LR}
    BL  _scanf_int 
    MOV R4, R0
    POP {PC}

_inverse:

    PUSH {LR}  
    VDIV.F32 S2, S1, S0
    VCVT.F64.F32 D4, S2 
    VMOV R1, R2, D4 
    POP {PC}
       
_printf:

    PUSH {LR}               @ push LR to stack
    LDR R0, =printf_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ pop LR from stack and return
    
_scanf:

    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return

_scanf_int:

    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_int     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return


.data

read_char:      .ascii      " "
format_str:     .asciz      "%f"
format_int:     .asciz      "%d"
printf_str:     .asciz      "%f\n"

