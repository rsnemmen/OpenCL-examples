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

#include "defs.h"
#include <clRNG/mrg31k3p.h>

/* uncomment to use single precision floating point numbers */
//#define CLRNG_SINGLE_PRECISION
#ifdef CLRNG_SINGLE_PRECISION
typedef cl_float fp_type;
#else
typedef cl_double fp_type;
#endif






int main(int argc, char *argv[]) {
	int ntarget, i;
	float *xa, *ya; 
	cl_int err;
	size_t localsize, globalsize;
	cl_mem streams_d, xa_d, ya_d; 	// Device input and output buffers
    size_t streamBufferSize;

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



	/* OpenCL
	   ========== 	*/
	cl_device_id device;
	cl_context context;
	cl_program program;
	cl_kernel kernel;
	cl_command_queue queue;

  	/* Create device and context; build program; command queue */
   	device = create_device(1); // 1=GPU, 0=CPU
   	context = clCreateContext(NULL, 1, &device, NULL, NULL, &err); error_check(err, "Couldn't create a context");
	program = build_program(context, device, PROGRAM_FILE);
	queue = clCreateCommandQueue(context, device, 0, &err); error_check(err, "Could not create a command queue");

	// RNG initialization
    clrngMrg31k3pStream* streams = clrngMrg31k3pCreateStreams(NULL, ntarget, &streamBufferSize, (clrngStatus *)&err);

	/* Create data buffer    */
    streams_d = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, streamBufferSize, streams, &err);	
	xa_d = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bytes, NULL, NULL);
	ya_d = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bytes, NULL, NULL);

	// Send data from host to device 
	//err = clEnqueueWriteBuffer(queue, xa_d, CL_TRUE, 0, bytes, xa, 0, NULL, NULL);
	//err |= clEnqueueWriteBuffer(queue, ya_d, CL_TRUE, 0, bytes, ya, 0, NULL, NULL);

	/* Kernel setup */
	kernel = clCreateKernel(program, KERNEL_FUNC, &err);	error_check(err, "Could not create a kernel");
	err = clSetKernelArg(kernel, 0, sizeof(streams_d), &streams_d); 
	err |= clSetKernelArg(kernel, 1, sizeof(xa_d), &xa_d); 
	err |= clSetKernelArg(kernel, 2, sizeof(ya_d), &ya_d); 
	err |= clSetKernelArg(kernel, 3, sizeof(unsigned int), &ntarget);
	
	// Get the maximum work group size for executing the kernel on the device
	err = clGetKernelWorkGroupInfo(kernel, device, CL_KERNEL_WORK_GROUP_SIZE, sizeof(localsize), &localsize, NULL);
	// Number of total work items - localSize must be devisor
	globalsize = ceil(ntarget/(float)localsize)*localsize;
	//printf("global size=%lu, local size=%lu\n", globalsize, localsize);

	/* Enqueue kernel 	*/
	err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalsize, &localsize, 0, NULL, NULL);	error_check(err, "Could not enqueue the kernel");
	clFinish(queue);

	/* Read the kernel's output    */
	clEnqueueReadBuffer(queue, xa_d, CL_TRUE, 0, bytes, xa, 0, NULL, NULL); 
	clEnqueueReadBuffer(queue, ya_d, CL_TRUE, 0, bytes, ya, 0, NULL, NULL); 

	/* Deallocate resources */
	clReleaseKernel(kernel);
	clReleaseMemObject(xa_d);
	clReleaseMemObject(ya_d);
	clReleaseCommandQueue(queue);
	clReleaseProgram(program);
	clReleaseContext(context);


	// Diagnostic messages
	// ====================
	/*for (i=0; i<ntarget; i++) {
		printf("x=%f, y=%f\n", xa[i],ya[i]);
	}*/

	return(0);	
}