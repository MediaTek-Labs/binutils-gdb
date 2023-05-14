#objdump: -dr
#name: Jump-table relaxation test with internal PC-relative branches

# Check correct relaxation of compressed jumptables.

.*: +file format .*nanomips.*

Disassembly of section \.text:

[0-9a-f]+ <test>:
       [0-9a-f]+:	20e6 2907 	lbux	a1,a2\(a3\)

[0-9a-f]+ <\$Lbu_nc_l0>:
#...
[0-9a-f]+ <\$Lbu_nc_l3>:
      [0-9a-f]+:	20e6 2b47 	lhuxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lbu_2_lhu_l0>:
#...
[0-9a-f]+ <\$Lbu_2_lhu_l3>:
     [0-9a-f]+:	20e6 2c47 	lwxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lbu_2_lwx_l0>:
#...
[0-9a-f]+ <\$Lbu_2_lwx_l3>:
    [0-9a-f]+:	20e6 2807 	lbx	a1,a2\(a3\)

[0-9a-f]+ <\$Lb_nc_l3>:
#...
[0-9a-f]+ <\$Lb_nc_l2>:
    [0-9a-f]+:	20e6 2a47 	lhxs	a1,a2\(a3\)
#...
[0-9a-f]+ <\$Lb_2_lh_l3>:
    [0-9a-f]+:	20e6 2a47 	lhxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lb_2_lh_neg_l3>:
#...
[0-9a-f]+ <\$Lb_2_lh_neg_l0>:
    [0-9a-f]+:	9008      	nop
#...
    [0-9a-f]+:	20e6 2c47 	lwxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lb_2_lwx_l0>:
#...
[0-9a-f]+ <\$Lb_2_lwx_l3>:
   [0-9a-f]+:	20e6 2c47 	lwxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lb_2_lwx_neg_l2>:
#...
[0-9a-f]+ <\$Lb_2_lwx_neg_l0>:
   [0-9a-f]+:	20e6 2b47 	lhuxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lhu_nc_l0>:
#...
[0-9a-f]+ <\$Lhu_nc_l3>:
   [0-9a-f]+:	20e6 2c47 	lwxs	a1,a2\(a3\)
#...
[0-9a-f]+ <\$Lhu_2_lwx_l3>:
#...
   [0-9a-f]+:	20e6 2a47 	lhxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lh_nc_l3>:
#...
[0-9a-f]+ <\$Lh_nc_l2>:
   [0-9a-f]+:	20e6 2c47 	lwxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lh_2_lwx_l0>:
#...
[0-9a-f]+ <\$Lh_2_lwx_l3>:
   [0-9a-f]+:	20e6 2c47 	lwxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lh_2_lwx_neg_l3>:
#...
[0-9a-f]+ <\$Lh_2_lwx_neg_l0>:
   [0-9a-f]+:	53eb      	lwxs	a1,a2\(a3\)

[0-9a-f]+ <\$Lw_nc_l3>:
#pass
