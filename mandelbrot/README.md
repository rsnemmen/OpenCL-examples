Computes Mandelbrot set. Example taken from the [Chlorine library](https://github.com/Polytonic/Chlorine/tree/master/examples/mandelbrot).  

```
mandelbrot.c
├── clbuild.c Auxiliary routines to build OpenCL programs
├── defs.h Header with useful definitions
└── mandelbrot.cl Kernel definition
```

I converted the code from C++ to C when appropriate.

My serial C code is running much faster than what was reported in the Chlorine library. I must be doing something wrong.