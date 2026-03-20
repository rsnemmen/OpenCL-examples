add_executable(rng_host host.c)
target_link_libraries(rng_host PRIVATE clRNG::clRNG)

add_executable(rng_device device.c clbuild.c)
target_link_libraries(rng_device PRIVATE OpenCL::OpenCL clRNG::clRNG)
target_include_directories(rng_device PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

configure_file(kernel.cl ${CMAKE_CURRENT_BINARY_DIR}/kernel.cl COPYONLY)
