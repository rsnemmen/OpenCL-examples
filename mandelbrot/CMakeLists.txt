add_executable(mandelbrot mandelbrot.c)
target_link_libraries(mandelbrot PRIVATE clhelpers m)

add_executable(mandelbrot_serial mandelbrot_serial.c)
target_link_libraries(mandelbrot_serial PRIVATE m)

configure_file(mandelbrot.cl ${CMAKE_CURRENT_BINARY_DIR}/mandelbrot.cl COPYONLY)
