#!/bin/sh
#
gcc `pkg-config --cflags cf4ocl2` mysum.c -o mysum `pkg-config --libs cf4ocl2`