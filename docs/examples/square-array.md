# square_array

Computes array² using the GPU. Combines elements from the `add_numbers` example (Matthew Scarpino) and the OLCF `vecAdd` example. Includes a serial CPU version for performance comparison.

| File | Description |
|------|-------------|
| `square.c` | Host code |
| `square.cl` | Kernel: computes element-wise square |
| `clbuild.c` | Auxiliary routines to build OpenCL programs |
| `defs.h` | Header with useful definitions |
| `square_serial.c` | Serial CPU version for comparison |

---

## Usage

### Build with CMake

```sh
cmake -B build && cmake --build build
cd build/square_array && ./square
```

### Build with Makefile

```sh
cd square_array && make run
```

### Run serial version

```sh
cd square_array && make serial
./square_serial
```

## Notes

Auxiliary OpenCL functions are separated into `clbuild.c` to keep the main routine readable. See [Architecture](../architecture.md) for details on the shared helper.
