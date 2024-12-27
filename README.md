## Build `riscv-gnu-toolchain` with P-Extension support
Issue [Reference](https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1291#issuecomment-1629237904)
```bash
git clone https://github.com/riscv-collab/riscv-gnu-toolchain riscv-collab-gnu-toolchain
cd riscv-collab-gnu-toolchain

git clone https://github.com/plctlab/riscv-gcc -b riscv-gcc-p-ext riscv-gcc-p-ext
git clone https://github.com/plctlab/riscv-binutils-gdb -b riscv-binutils-p-ext riscv-binutils-p-ext

# ./configure --prefix=`pwd`/build --with-arch=rv64imafd_zpn --with-abi=lp64d --with-gcc-src=`pwd`/riscv-gcc-p-ext --with-binutils-src=`pwd`/riscv-binutils-p-ext

# it looks like we need the hypervisor CSR and fence.i stuff for compiling pk 
./configure --prefix=`pwd`/build --with-arch=rv64gc_zicsr_zifencei_zpn --with-abi=lp64d --with-gcc-src=`pwd`/riscv-gcc-p-ext --with-binutils-src=`pwd`/riscv-binutils-p-ext

make

export RISCV=/workspace/riscv-collab-gnu-toolchain/build
export PATH=$RISCV/bin:$PATH
```

## Build `spike`
```bash
# NOTE: spike has to be built with the host gnu toolchain because spike needs to run on the host, not in an emulator

git clone https://github.com/riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim
mkdir build
cd build

../configure --with-target=riscv64-unknown-elf --prefix=$RISCV

make
make install

export SPIKE=/workspace/riscv-isa-sim/build
export PATH=$SPIKE:$PATH
```

## Build `pk`
```bash
# NOTE: pk has to be built with a toolchain built for the target architecture because it will be run in spike on that arch

export CC=riscv64-unknown-elf-gcc
export CXX=riscv64-unknown-elf-g++
export CFLAGS="-march=rv64gc_zicsr_zifencei_zpn"
export CXXFLAGS="-march=rv64gc_zicsr_zifencei_zpn"

cd /workspace/riscv-pk
rm -rf build
mkdir build
cd build

../configure --prefix=$RISCV --host=riscv64-unknown-elf CC=$CC CXX=$CXX CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"

make -j10
make install

# NOTE: pk is a RISC-V binary. riscv64-unknown-elf searches
#  for binaries in the cwd and in /path/to/riscv64-unknown-elf/bin so adding pk to the path will not work.
#  instead, a $PK var is used for locating the `pk` executable
export PK=/workspace/riscv-pk/build/pk
```

## Build and run `hello.c`
```bash
# Set up the environment first
source /workspace/setup_vars.sh
```

# Check compiler riscv extension support
```bash
# you should see "--with-arch=rv64gc_zicsr_zifencei_zpn" toward the end
# this tells us that the compiler has p ext support
riscv64-unknown-elf-gcc -v
```

```bash
cd /workspace/spike-test/hello-world-c

# Compile a test program
riscv64-unknown-elf-gcc -march=rv64gc_zicsr_zifencei_zpn hello.c -o hello

# Run the program with Spike
#   this is where i am currently hitting a wall.
#   this command does not seem to exit. it seems to use a lot of compute and there are no error codes
#   or anything. my current best bet is that the version of PK that i compiled with the p-extension,
#   causes issues. maybe because it should not be compiled with p ext support or maybe because
#   i have a version mismatch somewhere.
#
# Don't forget to use the --isa flag to specify which extensions you want.
# spike --isa=rv64imafdp $PK test
spike --isa=rv64gcp_zicsr_zifencei $PK hello
```

## Troubleshooting illegal instruction errors:

When encountering an illegal instruction error like this:
```bash
$ spike --isa=rv64gcp_zicsr_zifencei $PK test-p-ext2
# OUTPUT:
# bbl loader
# RISC-V P Extension SIMD Addition Demo
# z  0000000000000000 ra 000000000001022c sp 0000003ffffffb10 gp 000000000001ab50
# tp 0000000000000000 t0 0000000000000003 t1 0000000000000007 t2 000000000000008a
# s0 0000003ffffffb40 s1 0000000000000000 a0 000000000000000a a1 000000000001b360
# a2 0000000000000026 a3 0008000700060005 a4 0004000300020001 a5 0000003ffffffb10
# a6 0000000000000005 a7 0000000000000040 s2 0000000000000000 s3 0000000000000000
# s4 0000000000000000 s5 0000000000000000 s6 0000000000000000 s7 0000000000000000
# s8 0000000000000000 s9 0000000000000000 sA 0000000000000000 sB 0000000000000000
# t3 0000000000000005 t4 0000000000000000 t5 0000000000000001 t6 0000000000002190
# pc 0000000000010194 va/inst 0000000000d70777 sr 8000000200006020
# An illegal instruction was executed!
```

We can use the PC to find the exact location in the program that caused the error:
```bash
$ riscv64-unknown-elf-objdump -d test-p-ext2 | grep -B5 -A5 10194

# OUTPUT:
# 
#    10184:       fd040793                addi    a5,s0,-48
#    10188:       fe040713                addi    a4,s0,-32
#    1018c:       6318                    ld      a4,0(a4)
#    1018e:       fd840693                addi    a3,s0,-40
#    10192:       6294                    ld      a3,0(a3)
#    10194:       00d70777                radd16  a4,a4,a3   ## this line is highlighted red
#    10198:       e398                    sd      a4,0(a5)
#    1019a:       67e5                    lui     a5,0x19
#    1019c:       8b078513                addi    a0,a5,-1872 # 188b0 <__clzdi2+0x34>
#    101a0:       472000ef                jal     ra,10612 <puts>
#    101a4:       fe042623                sw      zero,-20(s0)
```
