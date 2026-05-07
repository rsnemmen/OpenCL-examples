# Hello World

A simple "Hello World" compute example showing basic usage of OpenCL. Calculates the mathematical square (X[i] = pow(X[i], 2)) for a buffer of floating point values.

Example downloaded from the [Apple OpenCL Developer website](https://developer.apple.com/opencl/).

| File | Description |
|------|-------------|
| `hello.c` | Host code with inlined kernel source |

---

## Usage

### Build with CMake

```sh
cmake -B build && cmake --build build
cd build/Hello_World && ./hello
```

### Build with Makefile

```sh
cd Hello_World && make run
```

This example is intended to be run from the command line. If run from within Xcode, open the Run Log (Command-Shift-R) to see the output.

## Requirements

- macOS 10.6 or later
- GPU: MacBook Pro with NVidia GeForce 8600M, or Mac Pro with NVidia GeForce 8800GT (to use GPU as compute device)
