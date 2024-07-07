	.linkrelax
	.module	pcrel
	.module	softfloat
	.section	.foo,"ax",@progbits
	.align	4
	.globl	foo
	.extern  bar
	.globl	__start
	.ent	foo
__start:
foo:
	move	$a0,$zero
	balc	bar
	jrc	$ra
	.end	foo
	.size	foo, .-foo
