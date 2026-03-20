cmake_minimum_required(VERSION 3.2)
set(OpenGL_GL_PREFERENCE GLVND)
set(NAME ray_traced_julia_set)

project(${NAME} C)

find_package(OpenCL REQUIRED)
find_package(OpenGL REQUIRED)
find_package(GLUT REQUIRED)

add_executable(${NAME} qjulia.c)
target_include_directories(${NAME} PRIVATE ${OpenCL_INCLUDE_DIRS} ${GLUT_INCLUDE_DIR} ${OPENGL_INCLUDE_DIR})
target_link_libraries(${NAME} m ${OpenCL_LIBRARY} ${OPENGL_LIBRARIES} ${GLUT_LIBRARIES})

configure_file(qjulia_kernel.cl qjulia_kernel.cl  COPYONLY)


message(OPENGL_INCLUDE_DIR: {${OPENGL_INCLUDE_DIR}})
message(OpenCL_INCLUDE_DIRS: {${OpenCL_INCLUDE_DIRS}})
message(GLUT_INCLUDE_DIR: {${GLUT_INCLUDE_DIR}})

message(OpenCL_LIBRARY: {${OpenCL_LIBRARY}})
message(OPENGL_LIBRARIES: {${OPENGL_LIBRARIES}})
message(GLUT_LIBRARIES: {${GLUT_LIBRARIES}})
