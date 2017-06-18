This example takes the square of an array using the GPU.

This is a combination of the [`add_numbers` code by Matthew Scarpino](http://www.drdobbs.com/parallel/a-gentle-introduction-to-opencl/231002854) and the [`vecAdd` example (OLCF)](https://www.olcf.ornl.gov/tutorials/opencl-vector-addition/). 

```
square.c
├── clbuild.c Auxiliary routines to build OpenCL programs
├── defs.h Header with useful definitions
└── square.cl Kernel definition
```

For comparison, `square_serial.c` is the serial code that performs the same task as `square.c`.

My contributions:

- put auxiliary OpenCL functions in separated file to clean up the main routine
- introduced header `defs.h`

