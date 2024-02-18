	.linkrelax
	.section	.text.__start,"ax",@progbits
	.align	1
	.globl	__start
	.type	__start, @function
__start:
	lapc	$r4,bar
	.size	__start, .-__start
