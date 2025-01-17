# Computational Engineering Seminar - P Extension

> Note: `/perf-tests/matmul` contains a set of matrix multiplication implementations, a Makefile to build/run them, a python script to automate instruction counting, as well as CSV results containing the numbers of instructions used for matrix multiplications on matrices starting at 8x8 going up to 120x120.

# Workflow

## Build and run docker container with all build dependencies
```bash
docker image build -t compeng-env .
./start_container.sh
```

## Build `riscv-gnu-toolchain` with P-Extension support
Issue [Reference](https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1291#issuecomment-1629237904)
```bash

cd /workspace

# clone gnu toolchain from riscv-collab organization (riscv-collab is downstream from riscv)
# i have validated that this commit works: 43536acae8791de5fc93acad51d0c03dda9f903e
git clone https://github.com/riscv-collab/riscv-gnu-toolchain riscv-collab-gnu-toolchain

cd riscv-collab-gnu-toolchain

git clone https://github.com/plctlab/riscv-gcc -b riscv-gcc-p-ext riscv-gcc-p-ext
git clone https://github.com/plctlab/riscv-binutils-gdb -b riscv-binutils-p-ext riscv-binutils-p-ext

# ./configure --prefix=`pwd`/build --with-arch=rv64imafd_zpn --with-abi=lp64d --with-gcc-src=`pwd`/riscv-gcc-p-ext --with-binutils-src=`pwd`/riscv-binutils-p-ext

# it looks like we need the hypervisor CSR and fence.i stuff for compiling pk 
./configure --prefix=`pwd`/build --with-arch=rv64gc_zicsr_zifencei_zpn --with-abi=lp64d --with-gcc-src=`pwd`/riscv-gcc-p-ext --with-binutils-src=`pwd`/riscv-binutils-p-ext

make -j$(nproc)

export RISCV=/workspace/riscv-collab-gnu-toolchain/build
export PATH=$RISCV/bin:$PATH
```

## Build `spike`
```bash
# NOTE: spike has to be built with the host gnu toolchain because spike needs to run on the host, not in an emulator

cd /workspace
git clone https://github.com/riscv-software-src/riscv-isa-sim.git

cd riscv-isa-sim
git checkout 37b0dc0b52b5536ab19af3a7678f1a1cd8087942 # this is the last commit that still has P extension support
mkdir build
cd build

../configure --with-target=riscv64-unknown-elf --prefix=$RISCV

make -j$(nproc)
make install

export SPIKE=/workspace/riscv-isa-sim/build
export PATH=$SPIKE:$PATH
```

## Build `pk`
```bash
# NOTE: pk has to be built with a toolchain built for the target architecture because it will be run in spike on that arch

cd /workspace
git clone https://github.com/riscv-software-src/riscv-pk.git

cd riscv-pk

# this is an older version of riscv-pk that does not rely on newly introduced CSRs
# that are not supported in the old versions of gcc/gdb that we are using
git checkout bc6e624fe1167b088af5694bb74eb68d61dde8ba

mkdir build
cd build

../configure \ 
    --prefix=$RISCV \ 
    --host=riscv64-unknown-elf \ 
    CC=riscv64-unknown-elf-gcc \ 
    CXX=riscv64-unknown-elf-g++ \ 
    CFLAGS="-march=rv64gc_zicsr_zifencei_zpn" \ 
    CXXFLAGS="-march=rv64gc_zicsr_zifencei_zpn"

make -j$(nproc)
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
# note: you will get some version incompatibility errors, these can be ignored for now
riscv64-unknown-elf-gcc -march=rv64gc_zicsr_zifencei_zpn hello.c -o hello

# Run the program with Spike
spike --isa=rv64gcp_zicsr_zifencei $PK hello
```

## Some references
- [PR where P-Ext support was added to spike](https://github.com/riscvarchive/riscv-gcc/pull/258)
- [Commit where P-Ext support was removed from spike](https://github.com/riscv-software-src/riscv-isa-sim/commit/c9468f6e024abb6d620ace295ef6e2e58e8f7eb2)
- [Working method to compile P-Ext code](https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1291#issuecomment-1629237904)
- [Toolchain P-Ext support discussion](https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1291)
- [Information how the P-Ext was split into subsets](https://github.com/riscv/riscv-p-spec/blob/c3409c8edb7df262cb3db0ff323077120e5f7f04/P-ext-proposal.adoc#5-p-extension-subsets)