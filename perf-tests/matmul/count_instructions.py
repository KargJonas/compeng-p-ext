import subprocess
import time
import os
import csv

def find_instruction_count(log_file):
    deadbeef_line = None
    cafecafe_line = None
    print(f"Searching for markers in {log_file}...")
    
    try:
        with open(log_file, 'r') as f:
            for i, line in enumerate(f, 1):
                if 'x31 0x00000000deadbeef' in line:
                    deadbeef_line = i
                    print(f"Found DEADBEEF marker at line {i}")
                elif 'x31 0x00000000cafecafe' in line:
                    cafecafe_line = i
                    print(f"Found CAFECAFE marker at line {i}")
                    break
                if i % 1000000 == 0:
                    print(f"Processed {i/1000000:.1f} million lines...")
    except Exception as e:
        print(f"Error reading file: {e}")
        return 0

    if deadbeef_line is None:
        print("Warning: DEADBEEF marker not found")
        return 0
    if cafecafe_line is None:
        print("Warning: CAFECAFE marker not found")
        return 0
        
    instructions = (cafecafe_line - deadbeef_line) // 2
    return instructions

def run_test(size, results):
    print(f"\nTesting matrix size: {size}x{size}")
    
    # Basic version
    print("Running basic version...")
    log_file = "/ramdisk/basic_log"
    if os.path.exists(log_file):
        os.remove(log_file)
    
    try:
        subprocess.run([
            "spike",
            "--isa=rv64gcp_zicsr_zifencei",
            "-l",
            "--log-commits",
            "--log", log_file,
            "/workspace/riscv-pk/build/pk",
            "./basic_packed_load",
            str(size)
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running basic version: {e}")
        return
    
    time.sleep(1)
    if not os.path.exists(log_file):
        print(f"Error: {log_file} was not created")
        return
    
    print(f"Log file size: {os.path.getsize(log_file)} bytes")
    basic_instructions = find_instruction_count(log_file)
    os.remove(log_file)
    
    # SIMD version
    print("\nRunning SIMD version...")
    log_file = "/ramdisk/simd_log"
    if os.path.exists(log_file):
        os.remove(log_file)
    
    try:
        subprocess.run([
            "spike",
            "--isa=rv64gcp_zicsr_zifencei",
            "-l",
            "--log-commits",
            "--log", log_file,
            "/workspace/riscv-pk/build/pk",
            "./simd",
            str(size)
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running SIMD version: {e}")
        return
    
    time.sleep(1)
    if not os.path.exists(log_file):
        print(f"Error: {log_file} was not created")
        return
        
    print(f"Log file size: {os.path.getsize(log_file)} bytes")
    simd_instructions = find_instruction_count(log_file)
    os.remove(log_file)
    
    print(f"\nResults for {size}x{size}:")
    print(f"  Basic: {basic_instructions} instructions")
    print(f"  SIMD:  {simd_instructions} instructions")
    if simd_instructions > 0:
        ratio = basic_instructions/simd_instructions
        print(f"  Ratio: {ratio:.2f}x")
    else:
        ratio = 0
        print("  Ratio: N/A (no instructions counted)")
        
    # Store results
    results.append({
        'matrix_size': size,
        'basic_instructions': basic_instructions,
        'simd_instructions': simd_instructions,
        'speedup_ratio': ratio
    })

def main():
    results = []
    for size in range(8, 128, 8):
        run_test(size, results)
        print("\n-------------")
        
    # Write results to CSV
    csv_file = 'matrix_multiplication_results.csv'
    fieldnames = ['matrix_size', 'basic_instructions', 'simd_instructions', 'speedup_ratio']
    
    with open(csv_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)
        
    print(f"\nResults have been saved to {csv_file}")

if __name__ == "__main__":
    main()