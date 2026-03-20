/*
Generates a lot of random numbers, then pick one and assing it
to the array.

-----------------

Code that contains kernels to run on accelerator in parallel. A kernel 
represents the basic unit of executable code. Each kernel will be 
executed on one work item ("pixel") of your parallel task:

1 work item = 1 "pixel" in your image 
*/

__kernel void waste(__global float* output, int n) {
	int i = get_global_id(0);
	int j;
	long rand;
	float x;

/* Since the work group size is used to tune performance and will 
not necessarily be a devisor of the total number of threads needed 
it is common to be 
forced to launch more threads than are needed and ignore the extras. 
After we check that we are inside of the problem domain we can access 
and manipulate the device memory.
*/
	if ((i >=0) && (i<n)) {

		// let's waste CPU time here, generating random numbers
		for (j=0; j<100; j++) {
			/* From this topic on random number generation for OpenCL:
			https://stackoverflow.com/a/14149151/793218
			*/
 			rand=i*j*as_float(i-j*i);
		 	rand*=rand<<32^rand<<16|rand;
		 	rand*=rand+as_double(rand);
			// our precious random number
			x = (float)rand;
		}		

		output[i]=x;
	}
}
