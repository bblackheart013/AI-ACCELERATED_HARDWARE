# AI Accelerated Vector Multiplication

A hardware implementation of parallel vector multiplication for AI acceleration.

## Author
Mohd Sarfaraz Faiyaz  
NetID: msf9335

## Project Overview
This project implements a hardware-accelerated vector multiplication system that demonstrates the performance benefits of parallelism in AI computations. The implementation includes:

- A parameterized vector multiplier in Verilog
- A host interface for CPU-hardware communication
- A parallel build system to optimize development time
- Performance analysis comparing hardware vs software implementations

## Directory Structur
```
vector_mult_accelerator/
├── include/          # Header files
├── src/
│   ├── vector_multiplier.v            # Hardware implementation
│   ├── vector_multiplier_tb.v         # Testbench
│   ├── host_interface.c               # Host interface
│   └── mac_performance_tester.c       # Performance testing tool
├── scripts/
│   └── parallel_build.py              # Parallel build script
├── build/            # Generated during build
├── Makefile          # Build automation
└── README.md         # This file
```
## Key Features
- Parameterized design supporting different vector sizes and data widths
- Parallel vector multiplication with O(1) time complexity
- Host interface for CPU control of the hardware accelerator
- Performance testing infrastructure to measure speedup
- Parallel build system for faster development

## Hardware Design
The core accelerator uses a generate block to create parallel multiplication units - one for each element in the vectors. This enables all elements to be multiplied simultaneously, providing:
- Constant-time vector multiplication regardless of size
- Linear performance improvement scaling with vector size
- Typical speedups of 10x-4000x for vector sizes 16-4096

## Building the Project

### Prerequisites
- Icarus Verilog (`iverilog`) for simulation
- GCC compiler for host interface
- Python 3 for build scripts

### Compilation
```bash
# Create build directory
mkdir -p build

# Compile and run simulation
make sim

# Run performance test (Mac compatibility version)
gcc -o build/performance_tester src/mac_performance_tester.c
./build/performance_tester
```

# Performance
This design demonstrates the fundamental principle behind AI hardware acceleration: parallelism. Theoretical speedup scales linearly with vector size:

| Vector Size | Theoretical Speedup |
|-------------|---------------------|
| 8           | 4.00x              |
| 64          | 56.89x             |
| 512         | 504.12x            |
| 4096        | 4088.02x           |

### Future Extensions
- Matrix multiplication implementation
- Convolution operations
- Activation functions
- Multi-layer neural network acceleration
