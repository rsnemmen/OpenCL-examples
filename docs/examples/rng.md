# RNG

Illustrates how to generate random numbers both on the host CPU and on the GPU using the [clRNG](http://clmathlibraries.github.io/clRNG/htmldocs/index.html) library.

**Dependencies:** clRNG

| File | Description |
|------|-------------|
| `host.c` | Generates random numbers on the host |
| `device.c` | Generates random numbers on the GPU |
| `kernel.cl` | Kernel that computes random numbers |
| `clbuild.c` | Auxiliary method to build kernel |
| `defs.h` | Definitions |

---

## Usage

### Build with CMake

clRNG must be installed and detectable. The example is silently skipped if clRNG is not found.

```sh
cmake -B build && cmake --build build
```

Run the host version:

```sh
cd build/rng && ./host
```

Run the GPU version:

```sh
cd build/rng && ./device
```

### Build with Makefile

```sh
cd rng && make run
```
