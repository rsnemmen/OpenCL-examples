add_executable(add_numbers add_numbers.c)
target_link_libraries(add_numbers PRIVATE OpenCL::OpenCL)

configure_file(add_numbers.cl ${CMAKE_CURRENT_BINARY_DIR}/add_numbers.cl COPYONLY)
