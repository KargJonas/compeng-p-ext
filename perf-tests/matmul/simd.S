	.file	"simd.c"
	.option nopic
	.attribute arch, "rv64i2p0_m2p0_a2p0_f2p0_d2p0_c2p0_zicsr2p0_zifencei2p0_zpn2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata.print_matrix.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"%6i "
	.section	.text.print_matrix,"ax",@progbits
	.align	1
	.globl	print_matrix
	.type	print_matrix, @function
print_matrix:
	beq	a1,zero,.L10
	addi	sp,sp,-64
	sd	s1,40(sp)
	sd	s2,32(sp)
	sd	s3,24(sp)
	sd	s4,16(sp)
	sd	s5,8(sp)
	sd	s6,0(sp)
	sd	ra,56(sp)
	sd	s0,48(sp)
	mv	s3,a1
	mv	s6,a0
	add	s1,a0,a1
	li	s5,0
	li	s4,0
	lui	s2,%hi(.LC0)
.L3:
	add	s0,s6,s5
.L4:
	lb	a1,0(s0)
	addi	a0,s2,%lo(.LC0)
	addi	s0,s0,1
	call	printf
	bne	s1,s0,.L4
	li	a0,10
	addi	s4,s4,1
	call	putchar
	add	s5,s5,s3
	add	s1,s1,s3
	bne	s3,s4,.L3
	ld	ra,56(sp)
	ld	s0,48(sp)
	ld	s1,40(sp)
	ld	s2,32(sp)
	ld	s3,24(sp)
	ld	s4,16(sp)
	ld	s5,8(sp)
	ld	s6,0(sp)
	addi	sp,sp,64
	jr	ra
.L10:
	ret
	.size	print_matrix, .-print_matrix
	.section	.text.transpose_matrix_inplace,"ax",@progbits
	.align	1
	.globl	transpose_matrix_inplace
	.type	transpose_matrix_inplace, @function
transpose_matrix_inplace:
	li	a5,1
	bleu	a1,a5,.L14
	addi	a6,a0,1
	addi	t3,a1,1
	neg	a0,a0
	li	a7,1
	addi	t1,a1,-1
.L16:
	add	a4,t1,a6
	mv	a5,a6
.L17:
	lb	a2,0(a4)
	lb	a3,0(a5)
	addi	a5,a5,1
	sb	a2,-1(a5)
	sb	a3,0(a4)
	add	a3,a5,a0
	add	a4,a4,a1
	bgtu	a1,a3,.L17
	addi	a7,a7,1
	add	a6,a6,t3
	sub	a0,a0,a1
	bne	a1,a7,.L16
.L14:
	ret
	.size	transpose_matrix_inplace, .-transpose_matrix_inplace
	.section	.text.matmul_simd,"ax",@progbits
	.align	1
	.globl	matmul_simd
	.type	matmul_simd, @function
matmul_simd:
	mv	t2,a1
	mv	t6,a2
	mv	t0,a3
	mv	a1,a4
	mv	t5,a5
 #APP
# 12 "simd.c" 1
	li x31, 0xDEADBEEF
# 0 "" 2
# 13 "simd.c" 1
	li x31, 0x0
# 0 "" 2
 #NO_APP
	beq	a3,zero,.L22
	beq	a5,zero,.L22
	add	t1,a2,a5
	mv	a6,a0
	li	t4,0
	li	t3,0
.L23:
	add	a7,t6,t4
	mv	a0,t2
.L26:
	li	a3,0
	beq	a1,zero,.L24
	li	a5,0
.L25:
	add	a4,a6,a5
	add	a2,a0,a5
	ld	a4,0(a4)
	ld	a2,0(a2)
 #APP
# 28 "simd.c" 1
	add8 a4, a4, a2
# 0 "" 2
# 37 "simd.c" 1
	add8 a3, a3, a4
# 0 "" 2
 #NO_APP
	addi	a5,a5,8
	bgtu	a1,a5,.L25
	slliw	a5,a3,16
	slliw	a4,a3,8
	sraiw	a5,a5,16
	sraiw	a4,a4,24
	sraiw	a5,a5,8
	addw	a5,a5,a4
	sraiw	a2,a3,24
	addw	a5,a5,a3
	slli	a4,a3,24
	addw	a5,a5,a2
	srai	a4,a4,56
	slli	a2,a3,16
	addw	a5,a5,a4
	srai	a2,a2,56
	slli	a4,a3,8
	addw	a5,a5,a2
	srai	a4,a4,56
	addw	a5,a5,a4
	srai	a3,a3,56
	addw	a3,a5,a3
	slliw	a3,a3,24
	sraiw	a3,a3,24
.L24:
	sb	a3,0(a7)
	addi	a7,a7,1
	add	a0,a0,a1
	bne	t1,a7,.L26
	addi	t3,t3,1
	add	t4,t4,t5
	add	t1,t1,t5
	add	a6,a6,a1
	bne	t0,t3,.L23
.L22:
 #APP
# 58 "simd.c" 1
	li x31, 0xCAFECAFE
# 0 "" 2
# 59 "simd.c" 1
	li x31, 0x0
# 0 "" 2
 #NO_APP
	ret
	.size	matmul_simd, .-matmul_simd
	.section	.rodata.main.str1.8,"aMS",@progbits,1
	.align	3
.LC1:
	.string	"Usage: %s <size>\n"
	.align	3
.LC2:
	.string	"size: matrix dimension (must be multiple of 8)"
	.align	3
.LC3:
	.string	"Error: size must be multiple of 8"
	.section	.text.startup.main,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sd	ra,40(sp)
	sd	s0,32(sp)
	sd	s1,24(sp)
	sd	s2,16(sp)
	sd	s3,8(sp)
	sd	s4,0(sp)
	li	a5,2
	beq	a0,a5,.L37
	ld	a1,0(a1)
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	printf
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	puts
	li	s1,1
.L38:
	ld	ra,40(sp)
	ld	s0,32(sp)
	ld	s2,16(sp)
	ld	s3,8(sp)
	ld	s4,0(sp)
	mv	a0,s1
	ld	s1,24(sp)
	addi	sp,sp,48
	jr	ra
.L37:
	ld	a0,8(a1)
	call	atoi
	andi	s1,a0,7
	mv	s0,a0
	bne	s1,zero,.L47
	mul	s4,a0,a0
	mv	a0,s4
	call	malloc
	mv	s3,a0
	mv	a0,s4
	call	malloc
	mv	s2,a0
	mv	a0,s4
	call	malloc
	sext.w	a5,s0
	li	a4,1
	mv	s4,a0
	bleu	a5,a4,.L40
	addi	t5,s0,1
	addi	t1,s2,1
	neg	a7,s2
	li	t3,1
	addi	t4,s0,-1
.L41:
	add	a3,t4,t1
	mv	a4,t1
.L42:
	lb	a6,0(a3)
	lb	a5,0(a4)
	addi	a4,a4,1
	sb	a6,-1(a4)
	sb	a5,0(a3)
	add	a5,a4,a7
	add	a3,a3,s0
	bgtu	s0,a5,.L42
	addi	t3,t3,1
	add	t1,t1,t5
	sub	a7,a7,s0
	bne	s0,t3,.L41
.L40:
	mv	a5,s0
	mv	a4,s0
	mv	a3,s0
	mv	a2,s4
	mv	a1,s2
	mv	a0,s3
	call	matmul_simd
	mv	a0,s4
	call	free
	mv	a0,s3
	call	free
	mv	a0,s2
	call	free
	j	.L38
.L47:
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	puts
	li	s1,1
	j	.L38
	.size	main, .-main
	.ident	"GCC: (g1da1a76d5d1) 10.2.0"
