cmake_minimum_required(VERSION 3.12)
project(opencl-examples C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find OpenCL (handles macOS framework vs Linux -lOpenCL automatically)
find_package(OpenCL REQUIRED)

# Platform-specific defines needed by source files
add_compile_definitions(UNIX CL_TARGET_OPENCL_VERSION=200)
if(APPLE)
    add_compile_definitions(MAC)
    # macOS ships OpenCL 1.2 only; inject a compat shim for OpenCL 2.0 APIs
    # used in the source files (e.g. clCreateCommandQueueWithProperties)
    add_compile_options(-include ${CMAKE_SOURCE_DIR}/cmake/cl_compat.h)
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

# Shared helper library (used by square_array, mandelbrot, waste)
add_subdirectory(common)

# Simple examples
add_subdirectory(Hello_World)
add_subdirectory(add_numbers)
add_subdirectory(sum_array)

# Examples using clhelpers
add_subdirectory(square_array)
add_subdirectory(mandelbrot)
add_subdirectory(waste)

# Device info utility (top-level queue.c)
add_executable(queue queue.c)
target_link_libraries(queue PRIVATE OpenCL::OpenCL)
# queue.c has a pre-existing pointer/int mismatch; suppress to keep source unchanged
target_compile_options(queue PRIVATE -Wno-int-conversion)

# Optional: examples requiring clRNG
find_package(clRNG QUIET)
if(clRNG_FOUND)
    add_subdirectory(auger)
    add_subdirectory(rng)
else()
    message(STATUS "clRNG not found — skipping auger and rng")
endif()
