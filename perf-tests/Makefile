CC = riscv64-unknown-elf-gcc
CFLAGS = -march=rv64gc_zicsr_zifencei_zpn

TARGET = simple_demo
SRC = simple_demo.c
SPIKE = spike
SPIKE_FLAGS = --isa=rv64gcp_zicsr_zifencei
PK ?= $(shell echo $$PK)  # Get proxy kernel path from environment

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $< -o $@

run: $(TARGET)
	$(SPIKE) $(SPIKE_FLAGS) $(PK) ./$(TARGET)

clean:
	rm -f $(TARGET)
