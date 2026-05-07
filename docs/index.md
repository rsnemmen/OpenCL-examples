# OpenCL Examples

Simple examples of OpenCL code for learning heterogeneous and GPU computing with OpenCL.

Examples marked with `*` have been reproduced to work in 2025 on AMD GPU.

| Example | Source directory | Description |
|---------|-----------------|-------------|
| [Hello World](examples/hello-world.md) | `Hello_World/` | OpenCL "Hello World" by Apple — computes X²  for a buffer of floats |
| [add_numbers](examples/add-numbers.md) `*` | `add_numbers/` | Adds a list of numbers together; includes detailed error handling |
| [sum_array](examples/sum-array.md) `*` | `sum_array/` | Sums two arrays (vector addition without error-handling boilerplate) |
| [square_array](examples/square-array.md) `*` | `square_array/` | Computes array² with a serial comparison version |
| [Mandelbrot](examples/mandelbrot.md) `*` | `mandelbrot/` | Mandelbrot set computation with serial comparison |
| [Waste](examples/waste.md) `*` | `waste/` | Compute cycle waster for benchmarking; includes serial comparison |
| [RNG](examples/rng.md) | `rng/` | Random number generation on host and GPU using clRNG |
| [Auger](examples/auger.md) `*` | `auger/` | Cosmic ray Monte Carlo simulation — **210x GPU speedup** |
| [N-Body Simulation](examples/n-body.md) | `N-BodySimulation/` | Gravity field simulation across CPU, GPU, and hybrid — requires Xcode |
| [Ray Traced Julia Set](examples/julia-set.md) | `RayTraced_Quaternion_Julia-Set_Example/` | Ray-traced 4D quaternion Julia set with OpenGL rendering |
| [cf4cl](examples/cf4cl.md) | `cf4cl/` | Example using the cf4ocl OpenCL wrapper for C |

The examples that most clearly demonstrate GPU computational advantage are `N-BodySimulation`, `RayTraced_Quaternion_Julia-Set_Example` (both by Apple), and `auger` (>200x speedup over serial CPU code).

## Dependencies

| Dependency | Purpose | Install |
|-----------|---------|---------|
| OpenCL | GPU compute framework | System-provided on macOS |
| clRNG | GPU random number generation | Required by `auger` and `rng` |
| cf4ocl | OpenCL C wrapper | Required by `cf4cl` |
| OpenGL/GLUT | Rendering | Required by `RayTraced_Quaternion_Julia-Set_Example` on Linux |
| clinfo | Device inspection | `brew install clinfo` |

---

To preview locally: `mkdocs serve`. To publish to GitHub Pages: `mkdocs gh-deploy`.
