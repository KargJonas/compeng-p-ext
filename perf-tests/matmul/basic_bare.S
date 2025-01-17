	.file	"basic_bare.c"
	.option nopic
	.attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0_zicsr2p0_zifencei2p0_zpn2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.matmul_basic,"ax",@progbits
	.align	1
	.globl	matmul_basic
	.type	matmul_basic, @function
matmul_basic:
	mv	t1,a0
	mv	t0,a3
	mv	t5,a1
	mv	t4,a4
	mv	a0,a5
	beq	a3,zero,.L1
	beq	a5,zero,.L1
	mv	t3,a2
	add	a6,t1,a4
	li	t6,0
.L3:
	li	a7,0
.L8:
	add	a3,t5,a7
	mv	a4,t1
	li	a5,0
	beq	t4,zero,.L7
.L4:
	lbu	a1,0(a4)
	lbu	a2,0(a3)
	addi	a4,a4,1
	add	a3,a3,a0
	maddr32	a5, a1, a2
	slliw	a5,a5,24
	sraiw	a5,a5,24
	bne	a4,a6,.L4
.L7:
	add	a4,t3,a7
	sb	a5,0(a4)
	addi	a7,a7,1
	bne	a0,a7,.L8
	addi	t6,t6,1
	add	t3,t3,a0
	add	t1,t1,t4
	add	a6,a6,t4
	bne	t0,t6,.L3
.L1:
	ret
	.size	matmul_basic, .-matmul_basic
	.ident	"GCC: (g1da1a76d5d1) 10.2.0"
