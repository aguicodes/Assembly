/******************************************************************************
* @ a simple calculator using floating point values using scanf and printf
* Some code is modified originally from
* @author Christopher D. McMurrough
******************************************************************************/
 
.global main
.func main
   
main:

    MOV R1, #1              @stores number 1 in register
    VMOV S1, R1             @moves 1 to float point register
    VCVT.F32.U32 S1, S1     @converts unsigned bit representation to single float
    B _main                 @branches into the loop main

_main:

    BL  _scanf              @branch to scanf procedure with return
    VMOV S0, R0             @move return value R0 to FPU register S0
    BL _getchar             @gets comparsion operator desired
    MOV R5, R0              @stores char character to R5
    B _compare              @branches off to compare
 
_getchar:

    PUSH {LR}               @store the return address
    MOV R7, #3              @ write syscall, 3
    MOV R0, #0              @ input stream from monitor, 0
    MOV R2, #1              @ read a single character
    LDR R1, =read_char      @ store the character in data memory
    SWI 0                   @ execute the system call
    LDR R0, [R1]            @ move the character to the return register
    AND R0, #0xFF           @ mask out all but the lowest 8 bits
    POP {PC}                @restore stack pointer and return

_compare:
      
    CMP R5, #'a'            @compares character to operation code char 'a'
    BEQ _abs                @ branches to function to execute and return 
    CMP R5, #'s'            @compares character to operation code char 's'
    BEQ _sqroot		    @ branches to function to execute and return 
    CMP R5, #'p'            @compares character to operation code char 'p'
    BEQ _pow                @ branches to function to execute and return 
    CMP R5, #'i'            @compares character to operation code char 'i'
    BEQ _inverse    	    @ branches to function to execute and return   

_abs:
 
    VABS.F32 S2,S0          @this operation gets ABS value of float input and stores in S2
    VCVT.F64.F32 D4,S2      @double precision
    VMOV R1, R2, D4         @split double VFP register into two ARM registers       
    BL  _printf             @branch to print and returns
    B main                  @loops back to main and restarts
   
_sqroot:

    VSQRT.F32 S2,S0         @this operation square roots the float input and stores in S2
    VCVT.F64.F32 D4,S2      @double precision
    VMOV R1, R2, D4         @split double VFP register into two ARM registers       
    BL  _printf             @branch to print and returns
    B main                  @loops back to main and restarts

_pow:

    BL  _scanf_int          @scanf integer input 
    MOV R9, R0              @store integer to R9
    VMOV S2, S0             @move float input to float register that processes operations
    MOV R6, #1              @start loop interation at 1
    MOV R3, #0              @move 0 to R3
    CMP R9, R3              @compare if power input is 0
    BEQ _one                @if so get ready to print 1
    B _loop                 @otherwise began loop iteration

_loop:
    
    CMP R9, R6              @if iteration equals input
    BEQ _endloop            @end this loop and get ready to print
    VMUL.F32 S2, S2, S0     @multiplies the floats and stores in float register S2
    ADD R6, R6, #1          @adds to iteration
    B _loop                 @execute loop again
   
_endloop: 
 
    VCVT.F64.F32 D4, S2     @converts to double precision
    VMOV R1, R2, D4         @split double VFP register into two ARM registers
    BL  _printf             @branch to print and returns
    B main                  @loops back to main and restarts

    
_one:
    VMOV S2, R6             @moves 1 to float point register
    VCVT.F32.U32 S2, S2     @converts unsigned bit representation to single float
    VCVT.F64.F32 D4, S2     @converts to double precision
    VMOV R1, R2, D4         @split double VFP register into two ARM registers
    BL _printf              @branch to print and returns
    B main                  @loops back to main and restarts

_inverse:

    VDIV.F32 S2, S1, S0     @divides the floats and stores in float register S2
    VCVT.F64.F32 D4, S2     @converts to double precision
    VMOV R1, R2, D4         @split double VFP register into two ARM registers
    BL  _printf             @branch to print and returns
    B main                  @loops back to main and restarts
    
_printf:

    PUSH {LR}               @store the return address
    LDR R0, =printf_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @restore stack pointer and return
    
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
