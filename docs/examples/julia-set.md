# Ray Traced Julia Set

Shows how to use OpenCL to raytrace a 4D quaternion Julia-set fractal and intermix the results of a compute kernel with OpenGL for rendering. The `.cl` compute kernel files are loaded and compiled at runtime.

**Dependencies:** OpenGL, GLUT (Linux only: `-lOpenGL -lGLU -lXi -lXmu -lglut`)

Example downloaded from the [Apple OpenCL Developer website](https://developer.apple.com/opencl/).

| File | Description |
|------|-------------|
| `qjulia.c` | Host code with OpenGL integration |
| `qjulia_kernel.cl` | Kernel: raytraces the quaternion Julia set |

### Theory references

- [Quaternion Julia sets (Bourke)](http://local.wasp.uwa.edu.au/~pbourke/fractals/quatjulia/)
- [Quaternion Julia Set Dynamics (Omegafield)](http://www.omegafield.net/library/dynamical/quaternion_julia_sets.pdf)
- [Ray Tracers for Julia Sets (Sandin, EVL/UIC)](http://www.evl.uic.edu/files/pdf/Sandin.RayTracerJuliaSetsbw.pdf)
- [Quaternion Julia Sets (Crane, Caltech)](http://www.cs.caltech.edu/~keenan/project_qjulia.html)

---

## Usage

### Build with CMake

```sh
cmake -B build && cmake --build build
cd build/RayTraced_Quaternion_Julia-Set_Example && ./qjulia
```

### Build with Makefile

```sh
cd RayTraced_Quaternion_Julia-Set_Example && make run
```

This example is intended to be run from the command line. If run from within Xcode, open the Run Log (Command-Shift-R) to see the output.

## Requirements

- macOS 10.7 or later (uses `float3` vector datatype, supported from 10.7)
- OpenCL 1.1
