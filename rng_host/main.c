/* 

*/

#include <clRNG/mrg31k3p.h>

int main(int argc, char *argv[]) {
    clrngMrg31k3pStream* streams = clrngMrg31k3pCreateStreams(NULL, 2, NULL, NULL);
    clrngMrg31k3pStream* single = clrngMrg31k3pCreateStreams(NULL, 1, NULL, NULL);

    int count = 0;
    for (int i = 0; i < 100; i++) {
        double u = clrngMrg31k3pRandomU01(&streams[i % 2]);
        int    x = clrngMrg31k3pRandomInteger(single, 1, 6);
        if (x * u < 2) count++;
    }

    printf("Average of indicators = %f\n", (double)count / 100.0);

	return(0);	
}