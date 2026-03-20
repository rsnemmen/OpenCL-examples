add_executable(hello hello.c)
target_link_libraries(hello PRIVATE OpenCL::OpenCL)
