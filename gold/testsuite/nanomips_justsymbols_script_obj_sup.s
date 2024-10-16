    .section .text, "ax", @progbits
    .align 1
    .globl fun
    .ent fun

fun:
    addiu $a1, $a2, 1
loop:
    bc loop

    .end fun
    .size fun, .-fun
