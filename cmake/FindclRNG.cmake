# FindclRNG.cmake
# Finds the clRNG library
#
# Imported targets:
#   clRNG::clRNG
#
# Result variables:
#   clRNG_FOUND
#   clRNG_INCLUDE_DIRS
#   clRNG_LIBRARIES

find_path(clRNG_INCLUDE_DIR
    NAMES clRNG/clRNG.h
    HINTS
        ${CMAKE_CURRENT_SOURCE_DIR}/clRNG/include
        ${CMAKE_CURRENT_SOURCE_DIR}/clRNG-1.0.0-beta-Linux64/include
        /usr/local/include
        /usr/include
)

find_library(clRNG_LIBRARY
    NAMES clRNG
    HINTS
        ${CMAKE_CURRENT_SOURCE_DIR}/clRNG
        ${CMAKE_CURRENT_SOURCE_DIR}/clRNG-1.0.0-beta-Linux64/lib64
        /usr/local/lib
        /usr/lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(clRNG
    REQUIRED_VARS clRNG_LIBRARY clRNG_INCLUDE_DIR
)

if(clRNG_FOUND AND NOT TARGET clRNG::clRNG)
    add_library(clRNG::clRNG UNKNOWN IMPORTED)
    set_target_properties(clRNG::clRNG PROPERTIES
        IMPORTED_LOCATION "${clRNG_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${clRNG_INCLUDE_DIR}"
    )
endif()

mark_as_advanced(clRNG_INCLUDE_DIR clRNG_LIBRARY)
