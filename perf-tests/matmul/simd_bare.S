	.file	"simd_bare.c"
	.option nopic
	.attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0_zicsr2p0_zifencei2p0_zpn2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.matmul_simd,"ax",@progbits
	.align	1
	.globl	matmul_simd
	.type	matmul_simd, @function
matmul_simd:
	mv	t2,a1
	mv	t0,a3
	mv	t6,a2
	mv	a1,a4
	mv	t5,a5
	beq	a3,zero,.L1
	beq	a5,zero,.L1
	add	t1,a2,a5
	mv	a6,a0
	li	t4,0
	li	t3,0
.L3:
	add	a7,t6,t4
	mv	a0,t2
.L7:
	li	a5,0
	li	a3,0
	beq	a1,zero,.L6
.L4:
	add	a4,a6,a5
	add	a2,a0,a5
	ld	a4,0(a4)		# Load A chunk
	ld	a2,0(a2)		# Load B chunk
	mul8 a4, a4, a2		# Simd multiplication of chunks
	add8 a3, a3, a4		# Simd accumulation of chunks
	addi	a5,a5,8		# k += 8
	bgtu	a1,a5,.L4	# Next loop iteration
	srli	a4,a3,16	# Perform horizontal sum only once
	srli	a5,a3,8
	addw	a5,a5,a4
	addw	a5,a5,a3
	srli	a4,a3,24
	addw	a5,a5,a4
	srli	a4,a3,32
	addw	a5,a5,a4
	srli	a4,a3,40
	addw	a5,a5,a4
	srli	a4,a3,48
	addw	a5,a5,a4
	srli	a3,a3,56
	addw	a3,a5,a3
	slliw	a3,a3,24
	sraiw	a3,a3,24
.L6:
	sb	a3,0(a7)
	addi	a7,a7,1
	add	a0,a0,a1
	bne	t1,a7,.L7
	addi	t3,t3,1
	add	t4,t4,t5
	add	t1,t1,t5
	add	a6,a6,a1
	bne	t0,t3,.L3
.L1:
	ret
	.size	matmul_simd, .-matmul_simd
	.ident	"GCC: (g1da1a76d5d1) 10.2.0"
