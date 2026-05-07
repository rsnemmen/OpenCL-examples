# Auger

Generates a mock sky of ultra-high-energy cosmic rays as expected from the Auger Observatory, using a Monte Carlo simulation. Demonstrates an impressive **210x GPU speedup** over a serial CPU implementation.

**Dependencies:** clRNG

```
main.c
├── defs.h       General libraries, including OpenCL
├── clbuild.c    For building kernel
└── cr.cl        Kernel
    └── exposure.clh  OpenCL header with helper function
```

---

## Usage

### Build with CMake

clRNG must be installed and detectable. The example is silently skipped if clRNG is not found.

```sh
cmake -B build && cmake --build build
cd build/auger && ./augerOCL
```

### Build with Makefile

```sh
cd auger && make run
```

## Performance

Benchmark on: GPU — Intel HD Graphics 5300, 24 compute units, 900 MHz; CPU — Intel Core M-5Y51 @ 1.10 GHz, 4 cores.

Generating 5,000,000 cosmic rays:

| Version | Time |
|---------|------|
| Serial on CPU | 4m 39.424s |
| Parallel on GPU | 1.33s |
| **Speedup** | **210x** |
