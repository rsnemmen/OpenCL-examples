# Waste

A compute cycle waster for GPU benchmarking. Intentionally burns compute cycles to measure throughput. Includes a serial CPU version for direct performance comparison.

| File | Description |
|------|-------------|
| `waste.c` | Host code |
| `waste.cl` | Kernel: wastes compute cycles |
| `clbuild.c` | Auxiliary routines to build OpenCL programs |
| `defs.h` | Header with useful definitions |
| `waste_serial.c` | Serial CPU version for comparison |

---

## Usage

### Build with CMake

```sh
cmake -B build && cmake --build build
cd build/waste && ./waste
```

### Build with Makefile

```sh
cd waste && make run
```
