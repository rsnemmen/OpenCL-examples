add_executable(augerOCL main.c clbuild.c)
target_link_libraries(augerOCL PRIVATE OpenCL::OpenCL clRNG::clRNG m)
target_include_directories(augerOCL PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

configure_file(cr.cl ${CMAKE_CURRENT_BINARY_DIR}/cr.cl COPYONLY)
