# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Educational OpenCL codebase with progressive examples for learning GPU computing. Projects range from simple kernels (add_numbers, square_array) to advanced simulations (auger cosmic ray Monte Carlo with >200x GPU speedup).

## Build Commands

Each subdirectory has its own Makefile. Build from within the project directory:

```bash
cd square_array && make        # build OpenCL version
cd square_array && make serial # build serial CPU version (where available)
```

Exceptions:
- `N-BodySimulation` and `RayTraced_Quaternion_Julia-Set_Example` use Xcode projects
- `cf4cl` uses `make.sh` shell script

The top-level `Makefile` builds `queue.c` (device info utility).

## Build System

All Makefiles use GCC with C99 (`-std=c99 -Wall -DUNIX -g -DDEBUG`) and auto-detect platform:
- **macOS**: `-DMAC -framework OpenCL`
- **Linux**: `-lOpenCL` with architecture detection (32/64-bit), optional AMD SDK or NVIDIA CUDA paths

## Code Architecture

Each project follows a consistent pattern:

- **Host code** (`.c`): Sets up OpenCL context, compiles kernel, manages buffers, launches kernel
- **Kernel code** (`.cl`): GPU-side computation
- **`clbuild.c` + `defs.h`**: Shared helper providing `create_device()` (GPU with CPU fallback) and `build_program()` (kernel compilation with error reporting). Used by: square_array, mandelbrot, auger, rng, waste.

The standard host code flow is: create device → create context/queue → build program → create buffers → set kernel args → enqueue kernel → read results → cleanup.

## Dependencies

- OpenCL framework (system-provided on macOS)
- [clRNG](http://clmathlibraries.github.io/clRNG/htmldocs/index.html) library (for `auger` and `rng` projects)
- [cf4ocl](https://github.com/fakenmc/cf4ocl) C wrapper (for `cf4cl` project)
- `clinfo` for device inspection: `brew install homebrew/science/clinfo`

## Serial Comparison Versions

`square_array`, `mandelbrot`, and `waste` include `*_serial.c` files for CPU vs GPU performance comparison.
