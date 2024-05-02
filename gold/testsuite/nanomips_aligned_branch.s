	.linkrelax
	.section	.call,"ax",@progbits
	.align	1
	.globl  call
	.ent	call
call:
	balc	foo
	.end	call
	.size	call, .-call

	.section	.tailcall,"ax",@progbits
	.align	1
	.globl  tailcall
	.ent	tailcall
tailcall:
	bc	foo
	.end	tailcall
	.size	tailcall, .-tailcall

	.section	.argcall,"ax",@progbits
	.align	1
	.globl  argcall
	.ent	argcall
argcall:
	move.balc $a0,$s0,foo
	.end	argcall
	.size	argcall, .-argcall

	.section	.foo,"ax",@progbits
	.align	1
	.globl	foo
	.ent	foo
foo:
	jrc	$ra
	.end	foo
	.size	foo, .-foo
