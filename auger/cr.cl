/* 
Performs the Monte Carlo simulation
=====================================
For each work item--element in the host xa,ya arrays--this kernel generates
a random UHECR position.
*/

// initialize pseudo-random number generator
srand(time(NULL)); 

// Loop that produces individual CRs
	while (1) {
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
			break;
		}
		
		//ntotal=ntotal+1;
	}
