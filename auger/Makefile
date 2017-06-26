CC	= gcc-6
FC = gfortran

FFLAGS = -O 
CFLAGS	= -fopenmp -O2  
#LFLAGS  = -g -O3

all: randomauger_omp randomauger

randomauger_omp: main_omp.c
	$(CC) $(CFLAGS) main_omp.c exposure.c -o randomauger_omp

randomauger: main.c
	$(CC) $(CFLAGS) main.c exposure.c -o randomauger

clean:
	rm -f *.o *.mod randomauger randomauger_omp

