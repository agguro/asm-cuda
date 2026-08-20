# ASM CUDA Kernels

A pure, low-level collection of modular NVIDIA CUDA / PTX guest kernels and assembly routines, completely decoupled from host code and structured for autonomous compilation.

## Repository Structure

The repository is organized by functional categories, where each kernel resides in its own self-contained leaf directory equipped with a local build target pointing to the shared template:

    asm-cuda/
    ├── basics/                 # Fundamental GPU verification and test kernels
    │   ├── gpu_clock/          # GPU cycle and clock measurement
    │   ├── gpu_hello/          # Basic execution test
    │   ├── gpu_pointertest/    # Pointer arithmetic and memory validation
    │   ├── gpu_thread_write/   # Concurrent thread writing tests
    │   └── gpu_write/          # Basic global memory write operations
    ├── docs/                   # Documentation and reference materials
    ├── finance/                # Financial and stochastic simulation kernels
    │   └── gbm_monte_carlo/    # Geometric Brownian Motion (Monte Carlo path simulation)
    ├── include/
    │   └── shared_kernel.mk    # Centralized, autonomous build template for all kernels
    ├── math/                   # Mathematical and vector operations
    │   ├── complex_quadratic_solver/ # Direct analytic solver for complex quadratic coefficients
    │   └── gpu_vector_add/     # Parallel vector addition
    └── LICENSE

## Build Instructions

Each kernel is completely autonomous. To build a specific kernel, navigate into its directory and use `make`:

    # Navigate to a specific kernel directory
    cd basics/gpu_clock

    # Build in DEBUG mode (includes line info and SASS disassembly dump)
    make debug

    # Build in RELEASE mode (optimized with -O3)
    make release

    # Clean build artifacts
    make clean

### Requirements
* NVIDIA CUDA Toolkit (`ptxas`, `nvdisasm`)
* GNU Make
