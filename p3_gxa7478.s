/******************************************************************************
* @file p3_gxa7478.s
* @Rand array, range 0-999, compute min/max, search value

******************************************************************************/

.global main
.func main
   
main:
    MOV R5, #0              @set to compare and overwrite if value is bigger
    LDR R6, =999            @set to compare and overwrite if value is smaller
    BL _seedrand            @ seed random number generator with current time
    MOV R0, #0              @ initialze index variable

writeloop:
    CMP R0, #10             @ check to see if we are done iterating
    BEQ writedone           @ exit loop if done
    LDR R1, =a              @ get address of a
    LSL R2, R0, #2          @ multiply index*4 to get array offset
    ADD R2, R1, R2          @ R2 now has the element address
    PUSH {R0}               @ backup iterator before procedure call
    PUSH {R2}               @ backup element address before procedure call
    BL _getrand             @ get a random number
    POP {R2}                @ restore element address
    STR R0, [R2]            @ write the address of a[i] to a[i]
    POP {R0}                @ restore iterator
    ADD R0, R0, #1          @ increment index
    B   writeloop           @ branch to next loop iteration

writedone:
    MOV R0, #0              @ initialze index variable

readloop:
    CMP R0, #10             @ check to see if we are done iterating
    BEQ readdone            @ exit loop if done
    LDR R1, =a              @ get address of a
    LSL R2, R0, #2          @ multiply index*4 to get array offset
    ADD R2, R1, R2          @ R2 now has the element address
    LDR R1, [R2]            @ read the array at address 
    PUSH {R0}               @ backup register before printf
    PUSH {R1}               @ backup register before printf
    PUSH {R2}               @ backup register before printf
    MOV R2, R1              @ move array value to R2 for printf
    MOV R1, R0              @ move array index to R1 for printf
    BL _min_max
    BL  _printf             @ branch to print procedure with return
    POP {R2}                @ restore register
    POP {R1}                @ restore register
    POP {R0}                @ restore register
    ADD R0, R0, #1          @ increment index
    B   readloop            @ branch to next loop iteration

_min_max:
    PUSH {LR}               @ store the return address
    CMP R5, R2              @ If value is larger, 
    MOVLT R5, R2            @ overwrite
    CMP R6, R2              @ If value is smaller,
    MOVGT R6, R2            @ overwrite
    POP {PC}		    @ restore the stack pointer and return

readdone:
    BL _print_min_max       @print min/max after rand array is done
    BL _prompt              @prompt for search value

_prompt:
    PUSH {R1}               @ backup
    PUSH {R2}               @ backup
    PUSH {R7}               @ backup
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #21             @ print string length
    LDR R1, =prompt_str     @ string at label prompt_str:
    SWI 0                   @ execute syscall
    PUSH {R1}               @ restore
    PUSH {R2}               @ restore
    PUSH {R7}               @ restore
    BL _scanf               @ ask for input value to search
    MOV R5, R0              @ move input int to registar
    MOV R6, #-1             @ initialize to -1
    MOV R0, #0              @ initialize index to 0
    MOV R1, #0              @ reset to 0
    MOV R2, #0              @ reset to 0
    BL _search              @ execute search

_search:
    CMP R0, #10             @ check to see if we are done iterating
    BEQ _print_index        @ exit loop if done
    LDR R1, =a              @ get address of a
    LSL R2, R0, #2          @ multiply index*4 to get array offset
    ADD R2, R1, R2          @ R2 now has the element address
    LDR R1, [R2]            @ read the array at address 
    CMP R5, R1              @ check if value matches input
    MOVEQ R6, R0            @ overwrite index if match found
    BEQ _print_index        @branch out and print index (no need to continue)
    ADD R0, R0, #1          @ increment index
    B   _search             @ branch to next loop iteration

_print_index: 
    MOV R1, R6              @ move index to print register
    LDR R0, =index_str      @ string to print
    BL printf               @ call printf
    BL _prompt              @ repeat cycle, prompting for search value

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

_printf:
    PUSH {LR}               @ store the return address
    LDR R0, =printf_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ restore the stack pointer and return

_print_min_max:
    PUSH {LR}               @ store the return address
    MOV R1, R6              @ move value to print register
    MOV R2, R5              @ move value to print register
    LDR R0, =min_max        @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ restore the stack pointer and return
 
_seedrand:
    PUSH {LR}               @ backup return address
    MOV R0, #0              @ pass 0 as argument to time call
    BL time                 @ get system time
    MOV R1, R0              @ pass sytem time as argument to srand
    BL srand                @ seed the random number generator
    POP {PC}                @ return 
    
_getrand:
    PUSH {LR}               @ backup return address
    BL rand                 @ get a random number
    MOV R1, R0              @ set value to 0 for mod
    MOV R2, #1000           @ set value to 0 for mod
    BL _mod_unsigned        @ execute mod
    POP {PC}                @ return 

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

.balign 4
a:              .skip       40
printf_str:     .asciz      "a[%d] = %d\n"
format_str:     .asciz      "%d"
min_max:        .asciz      "MINIMUM VALUE = %d\nMAXIMUM VALUE = %d\n"
prompt_str:     .asciz      "ENTER SEARCH VALUE: "
index_str:      .asciz      "%d\n"
debug_str:
.asciz "R%-2d   0x%08X  %011d \n"
exit_str:       .ascii      "Terminating program.\n"
