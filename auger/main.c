/* 
Write code that generates random UHECR events. This will be 
based off randomsky.f90 and exposure.f90. Write the events
in a text or binary file.

Produces an isotropic sky of Pierre Auger detections.
Given a target number of accepted events, this routine
will generate isotropic CRs until the desired number of detections
is reached. See astro-ph/0004016. Based on the routine randomsky.f90
that I previously wrote for Fortran.

Usage: randomsky n

:param n: = number of desired UHECR detections

This will be a good exercise in doing Monte Carlo simulations
in C.
*/

#include "exposure.h"
#include <omp.h>

int main(int argc, char *argv[]) {
	int ntarget, naccept, ntotal, i;
	float *xa, *ya; 
	float x, y, sampling;

	// read command-line argument
	if ( argc != 2 ) {
        printf( "Usage: %s ncosmic_rays \n", argv[0] );
        exit(0);
    } 
    sscanf(argv[1], "%i", &ntarget); 

    // dynamically allocate arrays
	xa = (float *)malloc(sizeof(float)*ntarget); 
	ya = (float *)malloc(sizeof(float)*ntarget); 

	// Equatorial coordinates of accepted events
	memset(xa, 0, sizeof(int)*ntarget); // initializes array to zeroes
	memset(ya, 0, sizeof(int)*ntarget);

	// Number of accepted events. Must reach naccept=target to start next trial
	naccept=0;
	//ntotal=0;	// total number of produced CRs

	/* 
	Performs the Monte Carlo simulation
	=====================================
	Be careful here. Distributing points uniformly in the (alpha,delta)
	plane does not correspond to a uniform random sky (spherical surface).
	Instead it will concentrate points towards the poles of the sphere.
	*/

	// initialize pseudo-random number generator
    srand(time(NULL)); 

	// Loop that produces individual CRs
	#pragma omp parallel shared(naccept,xa,ya) private(x,y,sampling) 
	{
		while (naccept < ntarget) {
			// random number between 0 and 360 
			x=((float)rand()/(float)(RAND_MAX)) * 360.;
			// random number between 0 and 1
			y=((float)rand()/(float)(RAND_MAX));

			// To avoid concentrations towards the poles, generates sin(delta)
			// between -1 and +1, then converts to delta
			y = asin(2.*y-1.)*180./M_PI;	// dec
			
			// If sampling<exposure for a given CR, it is accepted
			sampling=((float)rand()/(float)(RAND_MAX));

			if (sampling <= exposure(y)) {
				// Protects against racing condition
				#pragma omp atomic 
				naccept+=1; 
				xa[naccept]=x;
				ya[naccept]=y;
			}
			
			//ntotal=ntotal+1;
		}
	} // end omp

	// Diagnostic messages
	// ====================
	/*for (i=0; i<ntarget; i++) {
		printf("%f;%f  ", xa[i],ya[i]);
	}*/

	printf("Naccepted = %i \n", naccept);

	return(0);	
}