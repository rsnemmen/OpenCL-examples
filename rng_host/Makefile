CC	= gcc
FC = gfortran

FFLAGS = -O 
CFLAGS	= -framework OpenCL -O2 
LIBS = -lclRNG
#LFLAGS  = -g -O3

all: random

random: main.c
	$(CC) $(CFLAGS) $(LIBS) main.c -o rng_host

clean:
	rm -f *.o *.mod rng_host

