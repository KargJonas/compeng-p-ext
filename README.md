## Build `spike`
```bash
export SPIKE=/workspace/riscv-isa-sim/build
export PATH=$SPIKE:$PATH
```

## Build `pk`
```bash
export RISCV=/workspace/riscv-gnu-toolchain/build
export PATH=$RISCV/bin:$PATH

export CC=riscv64-unknown-elf-gcc
export CXX=riscv64-unknown-elf-g++
export CFLAGS="-march=rv64gc"
export CXXFLAGS="-march=rv64gc"

cd /workspace/riscv-pk
rm -rf build
mkdir build
cd build

../configure --prefix=$RISCV --host=riscv64-unknown-elf CC=$CC CXX=$CXX CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"

make -j10
make install

# NOTE: pk is a RISC-V binary. riscv64-unknown-elf has searches
#       for binaries in the cwd and in /path/to/riscv64-unknown-elf/bin
#       so adding pk to the path will not work.
#       having a $PK var is still useful for locating the `pk` executable
export PK=/workspace/riscv-pk/build/pk
```

## Build and run `hello.c`
```bash
# Compile a test program
riscv64-unknown-elf-gcc -o hello hello.c

# Run the program with Spike
spike $RISCV/riscv64-unknown-elf/bin/pk ./hello
```

Don't forget to use the --isa flag to specify which extensions you want.
```bash
spike $PK --isa=rv64gcv_zba_zbb_zbc_zbs ./hello
```

# Check compiler riscv extension support
```bash
riscv64-unknown-elf-gcc -march=help
```

If the list contains zba, zbb, zbc and zbs, the B extension should be supported.
