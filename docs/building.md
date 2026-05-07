# Building

## CMake (recommended)

CMake works on both macOS and Linux and is the recommended build method.

```sh
mkdir build && cd build
cmake ..
make
```

Each target is placed in its corresponding subdirectory under `build/`. Run executables from that subdirectory so the `.cl` kernel files are found at runtime:

```sh
cd build/square_array && ./square
```

Examples requiring [clRNG](http://clmathlibraries.github.io/clRNG/htmldocs/index.html) (`auger`, `rng`) are built automatically when clRNG is detected; they are silently skipped otherwise.

### macOS compatibility shim

macOS ships OpenCL 1.2 only. The file `cmake/cl_compat.h` maps OpenCL 2.0 APIs (e.g. `clCreateCommandQueueWithProperties`) to their 1.2 equivalents so the examples compile without modification.

## Makefiles (legacy)

Each example also has its own `Makefile`. Build from within the example directory:

```sh
cd <example> && make        # build OpenCL version
cd <example> && make run    # build and run
```

All Makefiles use GCC with C99 (`-std=c99 -Wall -DUNIX -g -DDEBUG`) and auto-detect the platform:

- **macOS**: `-DMAC -framework OpenCL`
- **Linux**: `-lOpenCL` with architecture detection (32/64-bit), optional AMD SDK (`AMDAPPSDKROOT`), NVIDIA CUDA paths, or AMD GPU Pro driver (`/opt/amdgpu-pro/`)

### Exceptions

| Example | Build method |
|---------|-------------|
| `N-BodySimulation` | Xcode project only |
| `RayTraced_Quaternion_Julia-Set_Example` | Makefile or CMakeLists.txt |
| `cf4cl` | `./make.sh` shell script |

The top-level `Makefile` builds `queue.c`, a device info utility.

## Inspecting your OpenCL devices

```sh
clinfo
```

Install on macOS:

```sh
brew install clinfo
```
