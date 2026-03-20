PROJ=mandelbrot

CC=gcc

#CFLAGS=-std=c99 -Wall -DUNIX -g -DDEBUG
CFLAGS=-std=c99 -Wall -DUNIX -g -DDEBUG -I /opt/amdgpu-pro/include -DCL_TARGET_OPENCL_VERSION=200
# No OpenCL
CFLAGSS=-std=c99 -Wall -DUNIX -g -DDEBUG 

LDFLAGS=-L /opt/amdgpu-pro/lib64 -lOpenCL

# Check for 32-bit vs 64-bit
PROC_TYPE = $(strip $(shell uname -m | grep 64))
 
# Check for Mac OS
OS = $(shell uname -s 2>/dev/null | tr [:lower:] [:upper:])
DARWIN = $(strip $(findstring DARWIN, $(OS)))

# MacOS System
ifneq ($(DARWIN),)
	CFLAGS += -DMAC
	LIBS=-framework OpenCL

	ifeq ($(PROC_TYPE),)
		CFLAGS+=-arch i386
	else
		CFLAGS+=-arch x86_64
	endif
else

# Linux OS
#LIBS=-lOpenCL
LIBS=-lm $(LDFLAGS)
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

$(PROJ): $(PROJ).c
	$(CC) $(CFLAGS) -o $@ $^ clbuild.c $(INC_DIRS:%=-I%) $(LIB_DIRS:%=-L%) $(LIBS)

run: $(PROJ)
	./$(PROJ)

.PHONY: clean

clean:
	rm -rf $(PROJ) ${PROJ}.dSYM
