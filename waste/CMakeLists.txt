add_executable(waste waste.c)
target_link_libraries(waste PRIVATE clhelpers m)

add_executable(waste_serial waste_serial.c)
target_link_libraries(waste_serial PRIVATE m)

configure_file(waste.cl ${CMAKE_CURRENT_BINARY_DIR}/waste.cl COPYONLY)
