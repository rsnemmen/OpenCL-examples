CC	= gcc
FC = gfortran

FFLAGS = -O 
CFLAGS	= -framework OpenCL -O2 
#LFLAGS  = -g -O3

all: randomauger_omp randomauger

randomauger_omp: main_omp.c
	$(CC) $(CFLAGS) $^ exposure.c -o randomauger_omp

randomauger: main.c
	$(CC) $(CFLAGS) $^ exposure.c -o randomauger

clean:
	rm -f *.o *.mod randomauger randomauger_omp

