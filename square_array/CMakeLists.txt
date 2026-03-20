add_executable(square square.c)
target_link_libraries(square PRIVATE clhelpers m)

add_executable(square_serial square_serial.c)
target_link_libraries(square_serial PRIVATE m)

configure_file(square.cl ${CMAKE_CURRENT_BINARY_DIR}/square.cl COPYONLY)
