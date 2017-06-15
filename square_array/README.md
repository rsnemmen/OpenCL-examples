This example takes the square of an array using the GPU.

This is a combination of the [`add_numbers` code by Matthew Scarpino](http://www.drdobbs.com/parallel/a-gentle-introduction-to-opencl/231002854) and the [`vecAdd` example (OLCF)](https://www.olcf.ornl.gov/tutorials/opencl-vector-addition/). 

My contributions:

- put auxiliary OpenCL functions in separated file to clean up the main routine
- introduced header `defs.h`

