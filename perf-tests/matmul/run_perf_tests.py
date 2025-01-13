import subprocess
import time
import os

def find_instruction_count(log_file):
    deadbeef_line = 0
    cafecafe_line = 0
    with open(log_file, 'r') as f:
        for i, line in enumerate(f, 1):
            if '0xdeadbeef' in line.lower():
                deadbeef_line = i
            elif '0xcafecafe' in line.lower():
                cafecafe_line = i
                break
    return (cafecafe_line - deadbeef_line) // 2

def run_test(size):
    print(f"\nTesting matrix size: {size}x{size}")
    
    # Basic version
    print("Running basic version...")
    log_file = "basic_log"
    if os.path.exists(log_file):
        os.remove(log_file)
    
    subprocess.run([
        "spike",
        "--isa=rv64gcp_zicsr_zifencei",
        "-l",
        "--log-commits",
        "--log", log_file,
        "/workspace/riscv-pk/build/pk",
        "./basic",
        str(size)
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Wait for file to be fully written
    time.sleep(1)
    basic_instructions = find_instruction_count(log_file)
    os.remove(log_file)
    
    # SIMD version
    print("Running SIMD version...")
    log_file = "simd_log"
    if os.path.exists(log_file):
        os.remove(log_file)
    
    subprocess.run([
        "spike",
        "--isa=rv64gcp_zicsr_zifencei",
        "-l",
        "--log-commits",
        "--log", log_file,
        "/workspace/riscv-pk/build/pk",
        "./simd",
        str(size)
    ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Wait for file to be fully written
    time.sleep(1)
    simd_instructions = find_instruction_count(log_file)
    os.remove(log_file)
    
    print(f"Results for {size}x{size}:")
    print(f"  Basic: {basic_instructions} instructions")
    print(f"  SIMD:  {simd_instructions} instructions")
    print(f"  Ratio: {basic_instructions/simd_instructions:.2f}x")

def main():
    for size in range(8, 65, 8):
        run_test(size)

if __name__ == "__main__":
    main()