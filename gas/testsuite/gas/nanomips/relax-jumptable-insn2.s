	.text
	.linkrelax
	.globl ext_sym
	.ent test
test:
	/* Load-byte unsigned - in range (no relaxation)  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lbu_nc_table
1:
	lbux	$a1,$a2($a3)
$Lbu_nc_l0:
	.section        .rodata,"a",@progbits
	.jumptable	1,3,1
lbu_nc_table:
	.byte ($Lbu_nc_l1 - $Lbu_nc_l0) >> 1
	.byte ($Lbu_nc_l2 - $Lbu_nc_l0) >> 1
	.byte ($Lbu_nc_l3 - $Lbu_nc_l0) >> 1
	.text
$Lbu_nc_l1:
	/* 51 MOVE.BALCS => 51*10 = 510 bytes  */
	.rept 50
	move.balc $a0, $a3, 1b
	.endr
$Lbu_nc_l2:
	move.balc $a0, $a3, 1b
$Lbu_nc_l3:
	/* Load-byte unsigned - relaxed to load half-word unsigned  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lbu_2_lhu_table
1:
	lbux	$a1,$a2($a3)
$Lbu_2_lhu_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	1,3,1
lbu_2_lhu_table:
	.byte ($Lbu_2_lhu_l1 - $Lbu_2_lhu_l0) >> 1
	.byte ($Lbu_2_lhu_l2 - $Lbu_2_lhu_l0) >> 1
	.byte ($Lbu_2_lhu_l3 - $Lbu_2_lhu_l0) >> 1
	.text
$Lbu_2_lhu_l1:
	/* 51 MOVE.BALCS => 51*10 = 510 bytes  */
	.rept 50
	move.balc $a0, $a3, 1b
	.endr
$Lbu_2_lhu_l2:
	move.balc $a0, $a3, 1b
	nop
$Lbu_2_lhu_l3:

	/* Load-byte unsigned - relaxed to load word signed  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lbu_2_lwx_table
1:
	lbux	$a1,$a2($a3)
$Lbu_2_lwx_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	1,3,1
lbu_2_lwx_table:
	.byte ($Lbu_2_lwx_l1 - $Lbu_2_lwx_l0) >> 1
	.byte ($Lbu_2_lwx_l2 - $Lbu_2_lwx_l0) >> 1
	.byte ($Lbu_2_lwx_l3 - $Lbu_2_lwx_l0) >> 1
	.text
$Lbu_2_lwx_l1:
	/* 10922 BEQCs + 2 NOP32 => 10922*12*+8 = 131072 (> 131070) bytes  */
	.rept 10922
	beqc $a0, $t0, 1f
	.endr
$Lbu_2_lwx_l2:
	nop32
	nop32
$Lbu_2_lwx_l3:

	/* Load-byte signed - in range (no relaxation)  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lb_nc_table
1:
	lbx	$a1,$a2($a3)
$Lb_nc_l3:
	/* 25 LAPCs + LAPC48 => 25*10 + 6 = -256 bytes  */
	.rept 25
	lapc $a0, 1b
	.endr
	lapc48 $a0, 1b
$Lb_nc_l0:
	.section        .rodata,"a",@progbits
	.jumptable	1,3,0
lb_nc_table:
	.sbyte ($Lb_nc_l1 - $Lb_nc_l0) >> 1
	.sbyte ($Lb_nc_l2 - $Lb_nc_l0) >> 1
	.sbyte ($Lb_nc_l3 - $Lb_nc_l0) >> 1
	.text
$Lb_nc_l1:
	/* 25 LAPCs + NOP32 => 25*10 + 4 = 254 bytes  */
	.rept	25
	lapc $a0, 1b
	.endr
	nop32
$Lb_nc_l2:

	/* Load-byte signed - relaxed to load half-word signed due to +ve overflow  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lb_2_lh_table
1:
	lbx	$a1,$a2($a3)
$Lb_2_lh_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	1,3,0
lb_2_lh_table:
	.sbyte ($Lb_2_lh_l1 - $Lb_2_lh_l0) >> 1
	.sbyte ($Lb_2_lh_l2 - $Lb_2_lh_l0) >> 1
	.sbyte ($Lb_2_lh_l3 - $Lb_2_lh_l0) >> 1
	.text
$Lb_2_lh_l1:
	/* 32 BCs => 32*8 => 256 bytes  */
	.rept 31
	bc ext_sym
	.endr
$Lb_2_lh_l2:
	bnec $a0, $a4, $Lb_nc_l2
	nop
$Lb_2_lh_l3:

	/* Load-byte signed - relaxed to load half-word signed due to -ve overflow  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lb_2_lh_neg_table
1:
	lbx	$a1,$a2($a3)
$Lb_2_lh_neg_l3:
	/* 21 BBEQZCs + 3 NOPs = 21*12+6 = -258 bytes */
	.rept 21
	bbeqzc $a7, 12, 1f
	.endr
$Lb_2_lh_neg_l2:
	nop
	nop
	nop
$Lb_2_lh_neg_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	1,3,0
lb_2_lh_neg_table:
	.sbyte ($Lb_2_lh_neg_l1 - $Lb_2_lh_neg_l0) >> 1
	.sbyte ($Lb_2_lh_neg_l2 - $Lb_2_lh_neg_l0) >> 1
	.sbyte ($Lb_2_lh_neg_l3 - $Lb_2_lh_neg_l0) >> 1
	.text
$Lb_2_lh_neg_l1:
	nop
	/* Load-byte signed - relaxed to load word signed due to +ve overflow  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lb_2_lwx_table
1:
	lbx	$a1,$a2($a3)
$Lb_2_lwx_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	1,3,0
lb_2_lwx_table:
	.sbyte ($Lb_2_lwx_l1 - $Lb_2_lwx_l0) >> 1
	.sbyte ($Lb_2_lwx_l2 - $Lb_2_lwx_l0) >> 1
	.sbyte ($Lb_2_lwx_l3 - $Lb_2_lwx_l0) >> 1
	.text
$Lb_2_lwx_l1:
	/* 8192 BCs => 8192*8 = 65536 bytes */
	.rept 8191
 	bc 1b
	.endr
$Lb_2_lwx_l2:
	bc 1b
$Lb_2_lwx_l3:

	/* Load-byte signed - relaxed to load word signed due to -ve overflow  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lb_2_lwx_neg_table
1:
	lbx	$a1,$a2($a3)
$Lb_2_lwx_neg_l3:
$Lb_2_lwx_neg_l2:
	lw	$a0,%gprel(x)($gp)
$Lb_2_lwx_neg_l1:
	.rept 8191
	bc 1b
	.endr
$Lb_2_lwx_neg_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	1,3,0
lb_2_lwx_neg_table:
	.sbyte ($Lb_2_lwx_neg_l1 - $Lb_2_lwx_neg_l0) >> 1
	.sbyte ($Lb_2_lwx_neg_l2 - $Lb_2_lwx_neg_l0) >> 1
	.sbyte ($Lb_2_lwx_neg_l3 - $Lb_2_lwx_neg_l0) >> 1
	.text

	/* Load half-word unsigned - in range (no relaxation)  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lhu_nc_table
1:
	lhuxs	$a1,$a2($a3)
$Lhu_nc_l0:
	.section        .rodata,"a",@progbits
	.jumptable	2,3,1
lhu_nc_table:
	.hword ($Lhu_nc_l1 - $Lhu_nc_l0) >> 1
	.hword ($Lhu_nc_l2 - $Lhu_nc_l0) >> 1
	.hword ($Lhu_nc_l3 - $Lhu_nc_l0) >> 1
	.text
$Lhu_nc_l1:
	/* 10922 BLTUCs + lapc = 10922*12 + 6 = 131070 */
	.rept 10922
	bltuc $a0, $a3, 1b
	.endr
$Lhu_nc_l2:
	lapc.b $a0, 1b
$Lhu_nc_l3:

	/* Load-hword unsigned - relaxed to load word signed due to overflow  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lhu_2_lwx_table
1:
	lhuxs	$a1,$a2($a3)
$Lhu_2_lwx_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	2,3,1
lhu_2_lwx_table:
	.hword ($Lhu_2_lwx_l1 - $Lhu_2_lwx_l0) >> 1
	.hword ($Lhu_2_lwx_l2 - $Lhu_2_lwx_l0) >> 1
	.hword ($Lhu_2_lwx_l3 - $Lhu_2_lwx_l0) >> 1
	.text
$Lhu_2_lwx_l1:
	/* 10922 BLTUCs + 2 LWs = 10922*12 + 8 = 131072 bytes */
	.rept 10922
	beqzc $s5, 1b
	.endr
$Lhu_2_lwx_l2:
	lw	$a0,%gprel(x)($gp)
	lw	$a0,%gprel(x)($gp)
$Lhu_2_lwx_l3:
	bc 1f

	/* Load half-word signed - in range (no relaxation)  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lh_nc_table
1:
	lhxs	$a1,$a2($a3)
$Lh_nc_l3:
	/* 6553 LAPCs + NOP =>  6553*10 + 4 = -65536 */
	.rept 6553
	lapc $a0, 1b
	.endr
$Lh_nc_l0:
	.section        .rodata,"a",@progbits
	.jumptable	2,3,0
lh_nc_table:
	.shword ($Lh_nc_l1 - $Lh_nc_l0) >> 1
	.shword ($Lh_nc_l2 - $Lh_nc_l0) >> 1
	.shword ($Lh_nc_l3 - $Lh_nc_l0) >> 1
	.text
$Lh_nc_l1:
	/* 6553 LAPCs + NOP =>  6553*10 + 4 = 65534 */
	.rept 6553
	lapc $a0, 1b
	.endr
	nop32
$Lh_nc_l2:

	/* Load-hword signed - relaxed to load word signed due to +ve overflow  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lh_2_lwx_table
1:
	lhxs	$a1,$a2($a3)
$Lh_2_lwx_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	2,3,0
lh_2_lwx_table:
	.shword ($Lh_2_lwx_l1 - $Lh_2_lwx_l0) >> 1
	.shword ($Lh_2_lwx_l2 - $Lh_2_lwx_l0) >> 1
	.shword ($Lh_2_lwx_l3 - $Lh_2_lwx_l0) >> 1
	.text
$Lh_2_lwx_l1:
	/* 5461 BNEICs + NOP32 =>  5461*12 + 4 = 65536 */
	.rept 5460
	bneic $a0, 5, 1f
	.endr
$Lh_2_lwx_l2:
	bneic $a0, 5, 1f
	nop32
$Lh_2_lwx_l3:
	/* Load-hword signed - relaxed to load word signed due to -ve overflow  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lh_2_lwx_neg_table
1:
	lhxs	$a1,$a2($a3)
$Lh_2_lwx_neg_l3:
	/* 5461 BLTICs + 2 NOP32 =>  5461*12 + 8 =  -65538 */
	.rept 5461
	bltic $a0, 21, 1f
	.endr
$Lh_2_lwx_neg_l2:
$Lh_2_lwx_neg_l1:
	nop32
	nop32
$Lh_2_lwx_neg_l0:
	.section        .rodata,"a",@progbits
	.align 1
	.jumptable	2,3,0
lh_2_lwx_neg_table:
	.shword ($Lh_2_lwx_neg_l1 - $Lh_2_lwx_neg_l0) >> 1
	.shword ($Lh_2_lwx_neg_l2 - $Lh_2_lwx_neg_l0) >> 1
	.shword ($Lh_2_lwx_neg_l3 - $Lh_2_lwx_neg_l0) >> 1
	.text

	/* Load word signed - in range (no relaxation)  */
	.reloc 1f, R_NANOMIPS_JUMPTABLE_LOAD, lw_nc_table
1:
	/* 5462 BEQICs = 5662*12 = 65544 */
	lwxs	$a1,$a2($a3)
$Lw_nc_l3:
	.rept 5462
	beqic $s0, 40, 1b
	.endr
$Lw_nc_l0:
	.section        .rodata,"a",@progbits
	.jumptable	4,3,0
lw_nc_table:
	.word ($Lw_nc_l1 - $Lw_nc_l0) >> 1
	.word ($Lw_nc_l2 - $Lw_nc_l0) >> 1
	.word ($Lw_nc_l3 - $Lw_nc_l0) >> 1
	.text
$Lw_nc_l1:
	.rept 6554
	lapc $a0, 1b
	.endr
$Lw_nc_l2:
	nop32

	.end test
