	.linkrelax
	.module	pcrel
	.module	softfloat
	.section	.bar,"ax",@progbits
	.align	4
	.globl	bar
	.extern  foo
	.ent	bar
__start:
bar:
	move	$a0,$zero
	balc	foo
	jrc	$ra
	.end	bar
	.size	bar, .-bar
