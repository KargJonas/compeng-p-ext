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
	mv	a6,a3
	mv	t4,a1
	beq	a3,zero,.L1
	mv	t1,a0
	mv	t3,a2
	add	a0,a0,a3
	li	t5,0
.L3:
	li	a7,0
.L6:
	add	a2,t4,a7
	mv	a4,t1
	li	a5,0
.L4:
	lb	a3,0(a4)
	lb	a1,0(a2)
	addi	a4,a4,1
	add	a2,a2,a6
	addw	a3,a3,a1
	addw	a5,a3,a5
	slli	a3,a5,48
	slliw	a5,a5,16
	srli	a3,a3,48
	sraiw	a5,a5,16
	bne	a0,a4,.L4
	add	a5,t3,a7
	sb	a3,0(a5)
	addi	a5,a7,1
	beq	a6,a5,.L5
	mv	a7,a5
	j	.L6
.L5:
	addi	a5,t5,1
	add	t3,t3,a6
	add	t1,t1,a6
	add	a0,a0,a6
	beq	a7,t5,.L1
	mv	t5,a5
	j	.L3
.L1:
	ret
	.size	matmul_basic, .-matmul_basic
	.ident	"GCC: (g1da1a76d5d1) 10.2.0"
