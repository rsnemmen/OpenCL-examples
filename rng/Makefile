CC	= gcc
FC = gfortran

FFLAGS = -O 
CFLAGS	= -framework OpenCL -O2 -DMAC
LIBS = -lclRNG
SRCS = clbuild.c

all: host device

host: host.c
	$(CC) $(CFLAGS) $(LIBS) $^ -o host

device: device.c
	$(CC) $(CFLAGS) $(LIBS) $^ $(SRCS) -o device

clean:
	rm -f *.o *.mod host device

