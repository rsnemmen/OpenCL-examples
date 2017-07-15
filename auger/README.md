Generates a Mock sky of ultra-high-energy cosmic rays as expected from Auger. 

```
main.c 
├── defs.h General libraries, including OpenCL
├── clbuild.c For building kernel
└── cr.cl Kernel
    └── exposure.clh OpenCL header with helper function
```

Here are some results comparing the execution time with a serial C version of the same code. My machine specs:

- GPU: Intel(R) HD Graphics 5300, 24 compute units, max clock frequency 900MHz
- CPU: Intel(R) Core(TM) M-5Y51 CPU @ 1.10GHz, 4 cores, max clock frequency 1200MHz

Time spent executing the code for generating 5000000 cosmic rays:

- Serial on CPU: 4m39.424s
- Parallel on GPU: 1.33s
- **Speedup factor = 210x**