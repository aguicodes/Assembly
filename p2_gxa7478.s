
/******************************************************************************
* file p2_gxa7478.s
* Graciela Aguilar
*GCD recursion
* most code was used from original author: Christopher D. McMurrough
******************************************************************************/
.global main
.func main
   
main:
    BL  _scanf              @ branch to scan procedure with return
    MOV R5, R0              @ store n in R4
    BL  _scanf              @ branch to scan procedure with return
    MOV R6, R0              @ store n in R5

    PUSH {R5}               @ store value to stack
    PUSH {R6}               @ store value to stack

    @ The reason to push/pop inputs, is to be able to print at the end

    MOV R1, R5              @ pass n1 to factorial procedure
    MOV R2, R6              @ pass n2 to factorial procedure
    BL  _GCD                @ branch to factorial procedure with return
    MOV R1, R5              @ pass n to printf procedure

    POP {R6}                @ restore values from stack
    POP {R5}                @ restore values from stack

    MOV R1, R5              @ copy first input to R1 to get ready to print
    MOV R2, R6              @ copy second input to R2 to get ready to print
    MOV R3, R0              @ copy mod result to R3 to get ready to print
    BL  _printf             @ branch to print procedure with return
    B   main                @ branch to exit procedure wit no return

_printf:
    PUSH {LR}               @ store the return address
    LDR R0, =printf_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ restore the stack pointer and return
   
_scanf:
    PUSH {LR}               @ store the return address
    PUSH {R1}               @ backup regsiter value
    LDR R0, =format_str     @ R0 contains address of format string
    SUB SP, SP, #4          @ make room on stack
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ remove value from stack
    POP {R1}                @ restore register value
    POP {PC}                @ restore the stack pointer and return
 
_GCD:
    PUSH {LR}               @ store the return address 
    MOV R1, R5              @ move to input argument for mod 
    MOV R2, R6              @ move to input argument for mod 
    CMP R2, #0              @ compare n2 to 0
    MOVEQ R0, R1            @ Return n1 if n2 equal to 0
    POPEQ {PC}              @ restore stack pointer and return if equal

    PUSH {R2}               @ backup input value
    BL  _mod_unsigned       @ compute the remainder of R1 / R2
    MOV R5, R2              @ copy R2 to R1 before mod
    MOV R6, R0              @ copy mod result to R2
    BL _GCD                 @ compute recursion
    POP {R2}                @ restore input value
    POP {PC}                @ restore the stack pointer and return

_mod_unsigned:
    cmp R2, R1              @ check to see if R1 >= R2
    MOVHS R0, R1            @ swap R1 and R2 if R2 > R1
    MOVHS R1, R2            @ swap R1 and R2 if R2 > R1
    MOVHS R2, R0            @ swap R1 and R2 if R2 > R1
    MOV R0, #0              @ initialize return value
    B _modloopcheck         @ check to see if
    _modloop:
        ADD R0, R0, #1      @ increment R0
        SUB R1, R1, R2      @ subtract R2 from R1
    _modloopcheck:
        CMP R1, R2          @ check for loop termination
        BHS _modloop        @ continue loop if R1 >= R2
    MOV R0, R1              @ move remainder to R0
    MOV PC, LR              @ return

.data
format_str:     .asciz      "%d"
printf_str:     .asciz      "The GCD of %d and %d is %d\n"
