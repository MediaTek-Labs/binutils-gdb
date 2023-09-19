.linkrelax
	.module	pcrel
	.section	.text.startup,"ax",@progbits
	.align	1

	.globl	test
	.ent	test
test:
	balc	subroutine
	balc	subroutine
	balc	subroutine
	balc	subroutine
	balc	subroutine
	balc	subroutine
	.rept 250
	nop[32]
	.endr
	balc	subroutine
	balc	subroutine
	balc	subroutine
	balc	subroutine
	balc	subroutine
	balc	subroutine
	.rept 512
	nop[32]
	.endr
	jrc	$ra
	.end	test
	.size	test, .-test

	.globl	subroutine
	.ent	subroutine
subroutine:
	nop
	jrc	$ra
	.end	subroutine
	.size	subroutine, .-subroutine
