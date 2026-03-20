add_executable(vecAdd vecAdd.c)
target_link_libraries(vecAdd PRIVATE OpenCL::OpenCL m)

configure_file(vecAdd.cl ${CMAKE_CURRENT_BINARY_DIR}/vecAdd.cl COPYONLY)
