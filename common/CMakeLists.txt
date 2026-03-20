add_library(clhelpers STATIC clbuild.c)
target_include_directories(clhelpers PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(clhelpers PUBLIC OpenCL::OpenCL)
