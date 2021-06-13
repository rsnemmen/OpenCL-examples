/* 
Performs the Monte Carlo simulation
=====================================
For each work item--element in the host xa,ya arrays--this kernel generates
a random UHECR position.

- x,y: RA and DEC for cosmic ray
- n: total number of cosmic rays desired
*/

#include <clRNG/mrg31k3p.clh>

#include "exposure.clh" 



__kernel void cr(__global clrngMrg31k3pHostStream* streams, __global float* xa, __global float* ya, const int n) {
	int i = get_global_id(0);
	float x,y,sampling;

	if (i>=n) 
		return;

	clrngMrg31k3pStream private_stream_d;   // This is not a pointer!
	clrngMrg31k3pCopyOverStreamsFromGlobal(1, &private_stream_d, &streams[i]);

	// Loop that produces individual CRs
	while (1) {
		// random number between 0 and 360 
		x=360.*clrngMrg31k3pRandomU01(&private_stream_d);
		// random number between 0 and 1
		y=clrngMrg31k3pRandomU01(&private_stream_d);

		// To avoid concentrations towards the poles, generates sin(delta)
		// between -1 and +1, then converts to delta
		y = asin((float)(2.*y-1.))*180./M_PI_F;	// dec
		
		// If sampling<exposure for a given CR, it is accepted
		sampling=clrngMrg31k3pRandomU01(&private_stream_d);

		if (sampling <= exposure(y)) {
			xa[i]=x;
			ya[i]=y;
			break;
		}
	} 
}