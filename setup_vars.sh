#!/bin/bash

export RISCV=/workspace/riscv-collab-gnu-toolchain/build
export PATH=$RISCV/bin:$PATH

export SPIKE=/workspace/riscv-isa-sim/build
export PATH=$SPIKE:$PATH

export PK=/workspace/riscv-pk/build/pk
