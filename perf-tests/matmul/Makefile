CC = riscv64-unknown-elf-gcc
CFLAGS = -march=rv64gc_zicsr_zifencei_zpn
SPIKE = spike
SPIKE_FLAGS = --isa=rv64gcp_zicsr_zifencei
PK ?= $(shell echo $$PK)  # Get proxy kernel path from environment

.PHONY: all clean run run-% asm

# Default target
all: main

# Generic compilation rule for any .c file
%: %.c
	$(CC) $(CFLAGS) $< -o $@

# Generate assembly for any .c file
asm:
	@if [ -z "$(word 2,$(MAKECMDGOALS))" ]; then \
		echo "Usage: make asm <file>"; \
		exit 1; \
	fi
	$(CC) $(CFLAGS) -O3 -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -S $(word 2,$(MAKECMDGOALS)).c -o $(word 2,$(MAKECMDGOALS)).S

# Support both "make run program" and "make run-program"
run: 
	@if [ -z "$(word 2,$(MAKECMDGOALS))" ]; then \
		echo "Usage: make run <program>"; \
		exit 1; \
	fi
	$(MAKE) run-$(word 2,$(MAKECMDGOALS))

run-%: %
	$(SPIKE) $(SPIKE_FLAGS) $(PK) ./$*

clean:
	rm -f main $(wildcard *.o) $(wildcard *.s)

# Special rule to allow the second argument to "make run" or "make asm" to be ignored
%:
	@:
