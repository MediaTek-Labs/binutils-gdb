	.linkrelax
	.section	.text,"ax",@progbits
	.align	4
	.globl	__start
	.ent	__start
__start:
	addiu	$r14,$gp, %gprel(var)
	addiu.b	$r16,$gp, %gprel(var)
	la	$r17, var
	addiu	$r14,$gp, %gprel(uvar)
	addiu.b	$r15,$gp, %gprel(uvar)

	.end	__start
	.size	__start, .-__start

	.section	.ssdata,"aw",@progbits
	.align	1
	.hword	1
	.globl	uvar
	.type	uvar, @object
	.size	uvar, 2
uvar:
	.hword	2
	.globl	var
	.type	var, @object
	.size	var, 4
var:
	.word	5
