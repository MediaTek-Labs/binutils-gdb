
    .section .text, "ax", @progbits
    .align 1
    .globl _start
    .ent _start

_start:
    bc _start
    .end _start
    .size _start, .-_start

