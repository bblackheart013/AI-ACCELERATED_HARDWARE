# parallel_build.py
# This script manages parallel synthesis of the vector multiplier
# for multiple configurations, improving build times

import os
import sys
import subprocess
import multiprocessing
import time
import argparse
from pathlib import Path


def create_config_file(vector_size, data_width, output_dir):
    """Create a configuration file for a specific vector size and data width"""
    config_content = f"""
// Auto-generated configuration
`define VECTOR_SIZE {vector_size}
`define DATA_WIDTH {data_width}
"""
    config_path = Path(output_dir) / f"config_{vector_size}_{data_width}.v"
    with open(config_path, "w") as f:
        f.write(config_content)
    return config_path


def run_synthesis(config_file, output_dir, vector_size, data_width):
    """Run the synthesis tool for a specific configuration"""
    start_time = time.time()

    # Create a custom build directory
    build_dir = Path(output_dir) / f"build_{vector_size}_{data_width}"
    os.makedirs(build_dir, exist_ok=True)

    # Define output files
    log_file = build_dir / "synthesis.log"

    # Run synthesis command (replace with your actual synthesis tool)
    # This is a placeholder - use your actual synthesis tool command
    cmd = [
        "iverilog",  # Replace with your synthesis tool
        "-o", str(build_dir / "vector_mult.out"),
        "-I", str(output_dir),
        "-D", f"VECTOR_SIZE={vector_size}",
        "-D", f"DATA_WIDTH={data_width}",
        "vector_multiplier.v"
    ]

    print(
        f"Starting synthesis for vector_size={vector_size}, data_width={data_width}")

    try:
        with open(log_file, "w") as f:
            process = subprocess.run(
                cmd, stdout=f, stderr=subprocess.STDOUT, check=True)

        duration = time.time() - start_time
        return (vector_size, data_width, True, duration)

    except subprocess.CalledProcessError:
        duration = time.time() - start_time
        return (vector_size, data_width, False, duration)


def main():
    parser = argparse.ArgumentParser(
        description="Parallel build script for vector multiplier")
    parser.add_argument("--output-dir", type=str, default="./build",
                        help="Output directory for build artifacts")
    parser.add_argument("--max-processes", type=int, default=multiprocessing.cpu_count(),
                        help="Maximum number of parallel synthesis processes")
    args = parser.parse_args()

    # Create output directory
    os.makedirs(args.output_dir, exist_ok=True)

    # Define configurations to synthesize
    # Format: (vector_size, data_width)
    configs = [
        (8, 16),
        (16, 16),
        (32, 16),
        (8, 32),
        (16, 32),
        (32, 32)
    ]

    print(f"Starting parallel synthesis with {args.max_processes} processes")
    print(f"Configurations to build: {len(configs)}")

    # Create all configuration files
    config_files = []
    for vector_size, data_width in configs:
        config_file = create_config_file(
            vector_size, data_width, args.output_dir)
        config_files.append((config_file, vector_size, data_width))

    # Run synthesis in parallel
    with multiprocessing.Pool(processes=args.max_processes) as pool:
        synthesis_args = [
            (config_file, args.output_dir, vector_size, data_width)
            for config_file, vector_size, data_width in config_files
        ]

        results = pool.starmap(run_synthesis, synthesis_args)

    # Print summary
    print("\nSynthesis Results:")
    print("-" * 60)
    print(f"{'Vector Size':<12} {'Data Width':<12} {'Status':<10} {'Duration (s)':<12}")
    print("-" * 60)

    successful = 0
    total_time = 0

    for vector_size, data_width, success, duration in results:
        status = "Success" if success else "Failed"
        print(f"{vector_size:<12} {data_width:<12} {status:<10} {duration:.2f}")

        if success:
            successful += 1
        total_time += duration

    print("-" * 60)
    print(f"Successfully built: {successful}/{len(configs)}")
    print(f"Total sequential time would be: {total_time:.2f}s")
    print(
        f"Parallel speedup: {total_time / (max(r[3] for r in results)):.2f}x")


if __name__ == "__main__":
    main()
