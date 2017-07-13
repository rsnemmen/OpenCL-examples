CC	= gcc
FC = gfortran

FFLAGS = -O 
CFLAGS	= -framework OpenCL -O2 -DMAC
LIBS = -lclRNG
SRCS = clbuild.c

all: augerocl

augerocl: main.c
	$(CC) $(CFLAGS) $(LIBS) $^ $(SRCS) -o augerocl

clean:
	rm -f *.o *.mod augerocl

