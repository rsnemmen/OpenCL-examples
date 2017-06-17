`cf4ocl` example
==================

Example on how to use the `cf4ocl` OpenCL wrapper for C. This is a library supposed to make using OpenCL kernels easier than dealing with the boilerplate code. 

Code taken from the [`cf4ocl` tutorial](http://www.fakenmc.com/cf4ocl/docs/latest/tut.html).

How to run:

1. Compile with `./make.sh`
2. Run with `./mysum`

You should get something similar to this output:

```
List of available OpenCL devices:

     0. Intel(R) Core(TM) M-5Y51 CPU @ 1.10GHz [Apple]
     1. Intel(R) HD Graphics 5300 [Apple]

 (?) Select device (0-1) > 
```

You need a comparable number of lines of `cf4ocl` code compared to opencl, so I do not see immediately an advantage…