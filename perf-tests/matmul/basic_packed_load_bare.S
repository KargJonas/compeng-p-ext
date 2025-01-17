	.file	"basic_packed_load_bare.c"
	.option nopic
	.attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0_zicsr2p0_zifencei2p0_zpn2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.matmul_packed_load,"ax",@progbits
	.align	1
	.globl	matmul_packed_load
	.type	matmul_packed_load, @function
matmul_packed_load:
	addi	sp,sp,-112
	sd	s0,104(sp)
	sd	s1,96(sp)
	sd	s2,88(sp)
	sd	s3,80(sp)
	sd	s4,72(sp)
	sd	s5,64(sp)
	sd	s6,56(sp)
	sd	s7,48(sp)
	sd	s8,40(sp)
	sd	s9,32(sp)
	sd	s10,24(sp)
	sd	s11,16(sp)
	sd	a1,0(sp)
	sd	a2,8(sp)
	beq	a3,zero,.L1
	mv	s8,a5
	beq	a5,zero,.L1
	mv	s9,a3
	mv	s3,a4
	add	s7,a2,a5
	mv	s5,a0
	li	s11,0
	li	s10,0
.L3:
	ld	a5,8(sp)
	ld	s4,0(sp)
	add	s6,a5,s11
.L7:
	li	a2,0
	li	a5,0
	beq	s3,zero,.L6
.L4:
	add	a3,s5,a2
	add	a4,s4,a2
	ld	a3,0(a3)		# Load A chunk
	ld	a4,0(a4)		# Load B chunk
	addi	a2,a2,8		# k += 8
	srli	s2,a3,8		# Extracting bytes from
	srli	s1,a4,8		# packed register
	srli	s0,a3,16
	srli	t2,a4,16
	srli	t0,a3,24
	srli	t6,a4,24
	srli	t5,a3,32
	srli	t4,a4,32
	srli	t3,a3,40
	srli	t1,a4,40
	srli	a7,a3,48
	srli	a6,a4,48
	srli	a0,a3,56
	srli	a1,a4,56
	maddr32	a5, a3, a4 	# Multiplication and accumulation
	maddr32	a5, s2, s1	# of extracted values
	maddr32	a5, s0, t2
	maddr32	a5, t0, t6
	maddr32	a5, t5, t4
	maddr32	a5, t3, t1
	maddr32	a5, a7, a6
	maddr32	a5, a0, a1
	slliw	a5,a5,24	# Clear overflow
	sraiw	a5,a5,24	# and sign-extend
	bgtu	s3,a2,.L4	# Next loop iteration
.L6:
	sb	a5,0(s6)
	addi	s6,s6,1
	add	s4,s4,s3
	bne	s6,s7,.L7
	addi	s10,s10,1
	add	s11,s11,s8
	add	s7,s7,s8
	add	s5,s5,s3
	bne	s9,s10,.L3
.L1:
	ld	s0,104(sp)
	ld	s1,96(sp)
	ld	s2,88(sp)
	ld	s3,80(sp)
	ld	s4,72(sp)
	ld	s5,64(sp)
	ld	s6,56(sp)
	ld	s7,48(sp)
	ld	s8,40(sp)
	ld	s9,32(sp)
	ld	s10,24(sp)
	ld	s11,16(sp)
	addi	sp,sp,112
	jr	ra
	.size	matmul_packed_load, .-matmul_packed_load
	.ident	"GCC: (g1da1a76d5d1) 10.2.0"
