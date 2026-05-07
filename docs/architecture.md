# Architecture

## Per-example structure

Each example follows the same host + kernel pattern:

| File | Role |
|------|------|
| `<name>.c` | Host code: sets up OpenCL context, compiles kernel, manages buffers, launches kernel, reads results |
| `<name>.cl` | Kernel code: GPU-side computation |
| `clbuild.c` | Shared helper (see below) |
| `defs.h` | Shared type definitions and includes |

The standard host code flow is:

```
create device → create context/queue → build program
  → create buffers → set kernel args → enqueue kernel
  → read results → cleanup
```

## Shared helper: `clbuild.c` and `defs.h`

`common/clbuild.c` provides two functions used by `square_array`, `mandelbrot`, `auger`, `rng`, and `waste`:

### `create_device()`

Finds a GPU or CPU associated with the first available platform. Tries GPU first (`CL_DEVICE_TYPE_GPU`); falls back to CPU (`CL_DEVICE_TYPE_CPU`) if no GPU is found. A platform identifies a vendor's installation — a system may have an NVIDIA platform and an AMD platform simultaneously.

### `build_program(ctx, dev, filename)`

Reads a `.cl` kernel file into a buffer, calls `clCreateProgramWithSource`, then `clBuildProgram`. On compile failure, retrieves and prints the build log via `clGetProgramBuildInfo` before exiting. The fourth parameter of `clBuildProgram` accepts compiler options similar to GCC flags (e.g. `-DMACRO=VALUE`, `-cl-opt-disable`).

### Which examples use it

| Uses `clbuild.c` | Inlines kernel source instead |
|-----------------|------------------------------|
| `square_array`, `mandelbrot`, `auger`, `rng`, `waste` | `Hello_World`, `add_numbers`, `sum_array` |

In the CMake build, `clbuild.c` and `defs.h` live in `common/` and are compiled into a shared library linked by the examples above. Per-directory Makefiles use local copies of these files.

## Serial comparison versions

`square_array`, `mandelbrot`, and `waste` each include a `*_serial.c` file — a plain C CPU implementation of the same computation — for direct CPU vs GPU performance comparison.
