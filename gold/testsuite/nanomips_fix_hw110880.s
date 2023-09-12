	.linkrelax
	.section	.text,"ax",@progbits
	.align	4
	.globl	__start
	.ent	__start
__start:
	# li[48] -> lapc[48].
	li $a0, foo
    # li[48] -> aluipc + ori.
	li $a1, bar
	li $a2, frob
	# addiu[48] -> lapc[48] + addu
	addiu $a3, foo
	# addiu[48] -> aluipc + ori + addu
	addiu $a4, bar
	addiu $a5, frob
	# lapc[48] -> aluipc + ori.
	lapc.b $t0, foo
	lapc.b $t1, bar
	swpc $t2, foo
	swpc $t3, bar
	.end	__start
	.size	__start, .-__start

	.section	.foo,"ax",@progbits
	.align	4
	.globl	foo
	.ent	foo
foo:
	jrc	$ra
	.end	foo
	.size	foo, .-foo
	.section	.bar,"ax",@progbits
	.align	4
	.globl	bar
	.ent	bar
bar:
	jrc	$ra
	.end	bar
	.size	bar, .-bar
	.section	.frob,"ax",@progbits
	.align	4
	.globl	frob
	.ent	frob
frob:
	jrc	$ra
	.end	frob
	.size	frob, .-frob
