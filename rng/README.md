Illustrates how to generate random numbers in the host and in the GPU using the library [`clRNG`](http://clmathlibraries.github.io/clRNG/htmldocs/index.html).

```
host.c Generates random numbers in the host
```

```
device.c Generates random numbers in the GPU
├── clbuild.c Auxiliary method to build kernel
├── kernel.cl Kernel that computes random numbers
└── defs.h Definitions
```

