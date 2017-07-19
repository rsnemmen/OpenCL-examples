# C
CC	= gcc
CFLAGS	= -O2 -std=c99 -Wall -DUNIX -g -DDEBUG

# Fortran
FC = gfortran
FFLAGS = -O 

# Additional libraries and source files
LIBS = -lm -lclRNG
SRCS = clbuild.c

# Check for 32-bit vs 64-bit
PROC_TYPE = $(strip $(shell uname -m | grep 64))
 
# Check for Mac OS
OS = $(shell uname -s 2>/dev/null | tr [:lower:] [:upper:])
DARWIN = $(strip $(findstring DARWIN, $(OS)))

# MacOS System
ifneq ($(DARWIN),)
	CFLAGS += -DMAC
	LIBS += -framework OpenCL
else
	# Linux OS
	LIBS += -lOpenCL
	ifeq ($(PROC_TYPE),)
		CFLAGS+=-m32
	else
		CFLAGS+=-m64
endif

# Check for Linux-AMD
ifdef AMDAPPSDKROOT
	INC_DIRS=. $(AMDAPPSDKROOT)/include
	ifeq ($(PROC_TYPE),)
		LIB_DIRS=$(AMDAPPSDKROOT)/lib/x86
	else
		LIB_DIRS=$(AMDAPPSDKROOT)/lib/x86_64
	endif
else
	# Check for Linux-Nvidia
	ifdef CUDA
	   INC_DIRS=. $(CUDA)/OpenCL/common/inc
	endif
endif
endif


all: augerOCL

augerOCL: main.c
	$(CC) $(CFLAGS) $^ $(SRCS) $(INC_DIRS:%=-I%) $(LIB_DIRS:%=-L%) -o $@ $(LIBS)

clean:
	rm -f *.o *.mod augerOCL
