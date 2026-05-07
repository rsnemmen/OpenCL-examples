# add_numbers

Adds a list of numbers together using the GPU. Includes detailed error handling, which makes the code more verbose but easier to follow for learning purposes.

Code taken from ["A Gentle Introduction to OpenCL" by Matthew Scarpino](http://www.drdobbs.com/parallel/a-gentle-introduction-to-opencl/231002854).

| File | Description |
|------|-------------|
| `add_numbers.c` | Host code with inlined kernel source and error handling |

---

## Usage

### Build with CMake

```sh
cmake -B build && cmake --build build
cd build/add_numbers && ./add_numbers
```

### Build with Makefile

```sh
cd add_numbers && make run
```
