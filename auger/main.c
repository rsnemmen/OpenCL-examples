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

#define PROGRAM_FILE "cr.cl"
#define KERNEL_FUNC "cr"

#include "exposure.h"
#include "defs.h"

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
	// Size, in bytes, of each vector
	size_t bytes = ntarget*sizeof(float);

	// Number of accepted events. Must reach naccept=target to start next trial
	naccept=0;
	//ntotal=0;	// total number of produced CRs



	/* OpenCL
	   ==========
	*/

	/* OpenCL structures */
	cl_device_id device;
	cl_context context;
	cl_program program;
	cl_kernel kernel;
	cl_command_queue queue;
	cl_int err;
	size_t local_size, global_size;
	// Device input and output buffers
	cl_mem dxa, dya;

  	/* Create device and context; build program; command queue */
   	device = create_device();
   	context = clCreateContext(NULL, 1, &device, NULL, NULL, &err);
	program = build_program(context, device, PROGRAM_FILE);
	queue = clCreateCommandQueue(context, device, 0, &err);

	/* Create data buffer    */
	dxa = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bytes, NULL, NULL);
	dya = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bytes, NULL, NULL);

	// Write our data set into the input array in device memory
	err = clEnqueueWriteBuffer(queue, dxa, CL_TRUE, 0, bytes, xa, 0, NULL, NULL);
	err |= clEnqueueWriteBuffer(queue, dya, CL_TRUE, 0, bytes, ya, 0, NULL, NULL);

	/* Create a kernel */
	kernel = clCreateKernel(program, KERNEL_FUNC, &err);
	/* Create kernel arguments 	*/
	err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &ddata); 
	err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &doutput); 
	err |= clSetKernelArg(kernel, 2, sizeof(unsigned int), &ARRAY_SIZE);
	
	// Get the maximum work group size for executing the kernel on the device
	err = clGetKernelWorkGroupInfo(kernel, device, CL_KERNEL_WORK_GROUP_SIZE, sizeof(localsize), &localsize, NULL);
	// Number of total work items - localSize must be devisor
	globalsize = ceil(ntarget/(float)localsize)*localsize;
	printf("global size=%u, local size=%u\n", globalsize, localsize);

	/* Enqueue kernel 	*/
	err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalsize, &localsize, 0, NULL, NULL); 
	clFinish(queue);

	/* Read the kernel's output    */
	clEnqueueReadBuffer(queue, dxa, CL_TRUE, 0, bytes, xa, 0, NULL, NULL); 
	clEnqueueReadBuffer(queue, dya, CL_TRUE, 0, bytes, ya, 0, NULL, NULL); // <=====GET OUTPUT

	/* Deallocate resources */
	clReleaseKernel(kernel);
	clReleaseMemObject(dxa);
	clReleaseMemObject(dya);
	clReleaseCommandQueue(queue);
	clReleaseProgram(program);
	clReleaseContext(context);




	// Diagnostic messages
	// ====================
	/*for (i=0; i<ntarget; i++) {
		printf("%f;%f  ", xa[i],ya[i]);
	}*/

	printf("Naccepted = %i \n", naccept);

	return(0);	
}