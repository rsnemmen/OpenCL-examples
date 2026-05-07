# Mandelbrot

Computes the Mandelbrot set on the GPU. Example taken from the [Chlorine library](https://github.com/Polytonic/Chlorine/tree/master/examples/mandelbrot), converted from C++ to C. Includes a serial CPU version for performance comparison.

| File | Description |
|------|-------------|
| `mandelbrot.c` | Host code |
| `mandelbrot.cl` | Kernel: computes Mandelbrot set iterations |
| `clbuild.c` | Auxiliary routines to build OpenCL programs |
| `defs.h` | Header with useful definitions |
| `mandelbrot_serial.c` | Serial CPU version for comparison |

---

## Usage

### Build with CMake

```sh
cmake -B build && cmake --build build
cd build/mandelbrot && ./mandelbrot
```

### Build with Makefile

```sh
cd mandelbrot && make run
```
