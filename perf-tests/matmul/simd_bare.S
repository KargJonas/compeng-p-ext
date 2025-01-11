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
	beq	a3,zero,.L12
	addi	sp,sp,-16
	addi	a5,sp,8
	mv	t5,a2
	add	a7,a2,a3
	mv	a6,a3
	mv	t6,a0
	mv	t0,a1
	li	t3,0
	li	t4,0
	add	a2,a3,a5
.L3:
	add	t1,t6,t3
	mv	a0,t0
	add	a1,t5,t3
.L5:
	ld	a4,0(t1)
	ld	a5,0(a0)
 #APP
# 14 "simd_bare.c" 1
	add8 a4, a4, a5
# 0 "" 2
 #NO_APP
	li	a5,0
	sd	a4,8(sp)
	addi	a4,sp,8
.L4:
	lb	a3,0(a4)
	addi	a4,a4,1
	addw	a5,a3,a5
	slli	a3,a5,48
	slliw	a5,a5,16
	srli	a3,a3,48
	sraiw	a5,a5,16
	bne	a2,a4,.L4
	sb	a3,0(a1)
	addi	a1,a1,1
	add	a0,a0,a6
	bne	a1,a7,.L5
	addi	t4,t4,1
	add	t3,t3,a6
	add	a7,a7,a6
	bne	a6,t4,.L3
	addi	sp,sp,16
	jr	ra
.L12:
	ret
	.size	matmul_simd, .-matmul_simd
	.ident	"GCC: (g1da1a76d5d1) 10.2.0"
