CC	= gcc
FC = gfortran

FFLAGS = -O 
CFLAGS	= -framework OpenCL -O2 
LIBS = -lclRNG
#LFLAGS  = -g -O3

all: host device

host: host.c
	$(CC) $(CFLAGS) $(LIBS) $^ -o host

device: device.c
	$(CC) $(CFLAGS) $(LIBS) $^ -o host

clean:
	rm -f *.o *.mod host device

