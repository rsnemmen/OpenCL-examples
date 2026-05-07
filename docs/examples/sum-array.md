# sum_array

OpenCL vector addition. Error handling is intentionally omitted so the structure of the code is more digestible — consider this a cleaner "Hello World" compared to `add_numbers`.

Downloaded from the [OLCF](https://www.olcf.ornl.gov/tutorials/opencl-vector-addition/).

| File | Description |
|------|-------------|
| `vecAdd.c` | Host code with inlined kernel source, no error handling |

---

## Usage

### Build with CMake

```sh
cmake -B build && cmake --build build
cd build/sum_array && ./vecAdd
```

### Build with Makefile

```sh
cd sum_array && make run
```
