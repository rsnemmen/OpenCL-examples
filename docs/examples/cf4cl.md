# cf4cl

Demonstrates how to use the [cf4ocl](https://github.com/nunofachada/cf4ocl/releases/) OpenCL wrapper library for C. cf4ocl is intended to reduce the boilerplate code required when writing OpenCL host programs. The library is now archived.

Code taken from the [cf4ocl tutorial](http://www.fakenmc.com/cf4ocl/docs/latest/tut.html).

**Dependencies:** cf4ocl

| File | Description |
|------|-------------|
| `mysum.c` | Host code using cf4ocl wrapper |
| `make.sh` | Build script |

---

## Usage

```sh
cd cf4cl
./make.sh
./mysum
```

Expected output (device list varies by machine):

```
List of available OpenCL devices:

     0. Intel(R) Core(TM) M-5Y51 CPU @ 1.10GHz [Apple]
     1. Intel(R) HD Graphics 5300 [Apple]

 (?) Select device (0-1) >
```

## Notes

The number of lines of cf4ocl code is comparable to plain OpenCL code for simple examples, so the advantage of the wrapper is not immediately obvious at this scale.
