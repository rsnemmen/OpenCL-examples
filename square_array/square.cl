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

__kernel void square(__global float* input, __global float* output, const int n) {
	int i = get_global_id(0);

	if ((i >=0) && (i<n)) {
		output[i]=input[i]*input[i];
	}
}
