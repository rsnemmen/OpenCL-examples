# Simple examples of OpenCL code

Simple examples of OpenCL code used to learn heterogeneous and GPU computing with OpenCL. 

**Documentation:** https://rsnemmen.github.io/OpenCL-examples/

## Examples included

`*` -- reproduced to work in 2025 on AMD GPU

- *`add_numbers`: add a list of numbers together. Includes detailed error handling which makes the code harder to read and understand
- *`square_array`: computes *array*^2 (I am playing mostly with this one)
- *`sum_array`: sums two arrays
- `cf4cl`: testing OpenCL C wrapper
- *`Hello_World`: OpenCL "Hello World" by Apple
- *`mandelbrot`: my attempt at a simple Mandelbrot set calculation
- `N-BodySimulation`: Apple's N-body simulator which clearly illustrates the speedup gained by using the GPU. Requires Xcode
- `RayTraced_Quaternion_Julia-Set_Example`: Apple's ray-traced quaternion Julia set renderer. Requires Xcode
- `rng`: Illustrates how to generate random numbers in the host and in the GPU using the library [`clRNG`](http://clmathlibraries.github.io/clRNG/htmldocs/index.html)
- `auger`: generates random cosmic rays on an isotropic sky
- *`waste`: compute cycle waster

The examples that clearly demonstrate the computational advantage of using a GPU for processing are `N-BodySimulation`, `RayTraced_Quaternion_Julia-Set_Example` (both developed by Apple programmers) and `auger`. For `auger`, I got impressive speedups of >200x compared to a serial code on the CPU.

## How to build

### CMake (recommended — works on macOS and Linux)

```bash
mkdir build && cd build
cmake ..
make
```

Each target is placed in its corresponding subdirectory under `build/`.  Run
executables from that subdirectory so the `.cl` kernel files are found:

```bash
cd build/square_array && ./square
```

Examples requiring [clRNG](http://clmathlibraries.github.io/clRNG/htmldocs/index.html)
(`auger`, `rng`) are built automatically when clRNG is detected; they are
silently skipped otherwise.

### Makefiles

Each example also has its own `Makefile`. Build from within the project directory:

```bash
cd <example> && make        # build OpenCL version
cd <example> && make run    # build and run
```

Exceptions: `N-BodySimulation` uses an Xcode project. `RayTraced_Quaternion_Julia-Set_Example` has a Makefile and CMakeLists.txt. `cf4cl` uses `make.sh`.

## Info about OpenCL devices

To learn about your OpenCL devices, try:

    clinfo

To install `clinfo` on MacOS:

    brew install clinfo


## TODO

- [ ] similar repo with CUDA examples

[![Buy Me a Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=nemmen&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/nemmen)
