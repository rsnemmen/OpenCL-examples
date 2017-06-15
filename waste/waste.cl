/*
Squares elements in an array.

Code that contains kernels to run on accelerator in parallel. A kernel 
represents the basic unit of executable code. Each kernel will be 
executed on one work item ("pixel") of your parallel task:

1 work item = 1 "pixel" in your image 

A practical application may generate thousands or even millions of 
work-items, but for the simple task of adding 64 numbers, 
eight work-items will suffice. 
*/

__kernel void square(__global float* input, __global float* output, int n) {
	int i = get_global_id(0);

/* Since the work group size is used to tune performance and will 
not necessarily be a devisor of the total number of threads needed 
it is common to be 
forced to launch more threads than are needed and ignore the extras. 
After we check that we are inside of the problem domain we can access 
and manipulate the device memory.
*/
	if ((i >=0) && (i<n)) {
		output[i]=input[i]*input[i];
	}
}
