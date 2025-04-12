# Makefile for Vector Multiplication Accelerator Project

# Directories
BUILD_DIR := build
SRC_DIR := src
INCLUDE_DIR := include
SCRIPT_DIR := scripts

# Tools
IVERILOG := iverilog
VVP := vvp
VERILATOR := verilator
CC := gcc
PYTHON := python3

# Files
VERILOG_SRC := $(SRC_DIR)/vector_multiplier.v
TESTBENCH := $(SRC_DIR)/vector_multiplier_tb.v
HOST_SRC := $(SRC_DIR)/host_interface.c
BUILD_SCRIPT := $(SCRIPT_DIR)/parallel_build.py

# Simulation output
SIM_OUT := $(BUILD_DIR)/vector_multiplier_sim

# Verilator output
VERILATOR_OUT := $(BUILD_DIR)/Vvector_multiplier

# Host application
HOST_APP := $(BUILD_DIR)/vector_mult_app

# Default configurations
VECTOR_SIZE ?= 8
DATA_WIDTH ?= 16

# Flags
IVERILOG_FLAGS := -I$(INCLUDE_DIR) -D VECTOR_SIZE=$(VECTOR_SIZE) -D DATA_WIDTH=$(DATA_WIDTH)
VERILATOR_FLAGS := --cc --build -I$(INCLUDE_DIR) -D VECTOR_SIZE=$(VECTOR_SIZE) -D DATA_WIDTH=$(DATA_WIDTH)
CFLAGS := -I$(INCLUDE_DIR) -D VECTOR_SIZE=$(VECTOR_SIZE) -D DATA_WIDTH=$(DATA_WIDTH) -O3 -Wall

# Number of parallel processes for build
PARALLEL_JOBS := 4

# Phony targets
.PHONY: all clean sim verilate host parallel help

# Default target
all: sim verilate host

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile Verilog design for simulation
$(SIM_OUT): $(VERILOG_SRC) $(TESTBENCH) | $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $^

# Run simulation
sim: $(SIM_OUT)
	$(VVP) $(SIM_OUT)

# Run Verilator to create C++ model
verilate: $(VERILOG_SRC) | $(BUILD_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) $< --top-module vector_multiplier -o $(VERILATOR_OUT)

# Compile host application
$(HOST_APP): $(HOST_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -o $@ $^ -lrt

# Build host application
host: $(HOST_APP)

# Run parallel build script
parallel: $(BUILD_SCRIPT)
	$(PYTHON) $(BUILD_SCRIPT) --output-dir $(BUILD_DIR) --max-processes $(PARALLEL_JOBS)

# Build multiple configurations in parallel
configs:
	$(MAKE) VECTOR_SIZE=8 DATA_WIDTH=16 -j
	$(MAKE) VECTOR_SIZE=16 DATA_WIDTH=16 -j
	$(MAKE) VECTOR_SIZE=32 DATA_WIDTH=16 -j
	$(MAKE) VECTOR_SIZE=8 DATA_WIDTH=32 -j
	$(MAKE) VECTOR_SIZE=16 DATA_WIDTH=32 -j
	$(MAKE) VECTOR_SIZE=32 DATA_WIDTH=32 -j

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Help target
help:
	@echo "Vector Multiplication Accelerator Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build simulation, Verilator model, and host application"
	@echo "  sim       - Compile and run simulation"
	@echo "  verilate  - Generate C++ model using Verilator"
	@echo "  host      - Compile host application"
	@echo "  parallel  - Run parallel build script"
	@echo "  configs   - Build multiple configurations"
	@echo "  clean     - Remove build artifacts"
	@echo ""
	@echo "Configuration:"
	@echo "  VECTOR_SIZE  - Size of vectors (default: $(VECTOR_SIZE))"
	@echo "  DATA_WIDTH   - Width of data elements (default: $(DATA_WIDTH))"
	@echo "  PARALLEL_JOBS - Number of parallel jobs (default: $(PARALLEL_JOBS))"