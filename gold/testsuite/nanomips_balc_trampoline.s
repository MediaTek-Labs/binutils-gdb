    .linkrelax
    .module pcrel

    .section .before_text, "ax", @progbits
    .align 1
    .globl before_start
    .ent before_start

before_start:
    balc fun
    .end before_start
    .size before_start, .-before_start

    .section .with_text, "ax", @progbits
    .align 1
    .globl with_start
    .ent with_start

with_start:
    balc fun
    .end with_start
    .size with_start, .-with_start

    .section .text, "ax", @progbits
    .align 1

    .globl _start
    .ent _start

_start:
    balc fun
    balc fun
    balc fun
    lapc $a1, a
    balc fun
    .skip 0x3f8
    balc fun
    .end _start
    .size _start, .-_start

    .section .with_text_after, "ax", @progbits
    .align 1

    .globl with_start_after
    .ent with_start_after

with_start_after:
    balc fun
    .end with_start_after
    .size with_start_after,.-with_start_after

    .section .other_text, "ax", @progbits
    .align 1

    .globl fun
    .ent fun

fun:
    addiu $a2, $a2, 1
    .end fun
    .size fun, .-fun


    .section .tramp_expansion, "ax", @progbits
    .align 1

    .globl expand
    .ent expand

expand: 
    balc fun
    balc fun
    balc fun
    balc fun
    .skip 0x3f4
    addiu $a2, $a2, 1
    lapc $a1, long_dist_fun
    balc fun

    .end expand
    .size expand, .-expand

    .section .align_section, "ax", @progbits
    .align 1

    .globl align_fun
    .ent align_fun

align_fun:
    
    balc fun
    balc fun
    .align 4
    balc fun
    balc fun

    .end align_fun
    .size align_fun, .-align_fun

    .section .a_section, "ax", @progbits
    .align 1

    .globl a
    .ent a
a:
    addiu $a2, $a2, 1
b:
    .end a
    .size a, .-a

    .section .long_distance, "ax", @progbits
    .align 1

    .globl long_dist_fun
    .ent long_dist_fun

long_dist_fun:
    addiu $a1, $a2, 3

    .end long_dist_fun
    .size long_dist_fun, .-long_dist_fun

    .section .transform_bc_section, "ax", @progbits
    .align 1

    .globl transform_bc_fun
    .ent transform_bc_fun

transform_bc_fun:
    balc c
    balc c
    balc c
    lapc $a2, d
    lapc $a2, d + 4
    balc c

    .end transform_bc_fun
    .size transform_bc_fun, .-transform_bc_fun

.equ c, 0x000018
.equ d, 0x220000e
