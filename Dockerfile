FROM ubuntu:latest

# Helps avoid some prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update
RUN apt-get update

# Some essential packages
RUN apt-get install -y \
    # Build/dev utilities
    pkg-config \
    software-properties-common \
    build-essential \
    cmake \
    git

# RISC-V GNU Compiler Toolchain-specific
RUN apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    curl \
    python3 \
    python3-pip \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    build-essential \
    bison flex \
    texinfo gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    libexpat-dev \
    ninja-build \
    libglib2.0-dev \
    libslirp-dev \
    cmake \
    git

# Spike-specific
RUN apt-get install -y \
    device-tree-compiler \
    libboost-regex-dev \
    libboost-system-dev

RUN apt-get clean

# Set the working directory
WORKDIR /workspace

ENV RISCV=/workspace/riscv-collab-gnu-toolchain/build
ENV SPIKE=/workspace/riscv-isa-sim/build
ENV PK=/workspace/riscv-pk/build/pk
ENV PATH=$RISCV/bin:$SPIKE:$PATH

# Set default command
CMD ["/bin/bash"]
