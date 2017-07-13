/* 
Taken from http://clmathlibraries.github.io/clRNG/htmldocs/index.html.
*/

#define PROGRAM_FILE "kernel.cl"
#define KERNEL_FUNC "example"

#include "defs.h"
#include <clRNG/mrg31k3p.h>

int main(int argc, char *argv[]) {
    cl_int err;
    size_t localsize, globalsize;
    cl_mem in_d, out_d; 
    size_t streamBufferSize;
    int numWorkItems;
    float *out_h;
    int i;

    // read command-line argument
    if ( argc != 2 ) {
        printf( "Usage: %s n \n", argv[0] );
        exit(0);
    } 
    sscanf(argv[1], "%i", &numWorkItems); 

    // dynamically allocate arrays
    out_h = (float *)malloc(sizeof(float)*numWorkItems); 

    /* OpenCL ==============================================*/
    cl_device_id device;
    cl_context context;
    cl_program program;
    cl_kernel kernel;
    cl_command_queue queue;

    /* Create device and context; build program; command queue */
    device = create_device();
    context = clCreateContext(NULL, 1, &device, NULL, NULL, &err);
    program = build_program(context, device, PROGRAM_FILE);
    queue = clCreateCommandQueue(context, device, 0, &err);

    /* Now suppose we have an integer variable numWorkItems that 
    indicates the number of work items we want to use. We create an 
    array of numWorkItems streams (and allocate memory for both the 
    array and the stream objects). The creator returns in the variable 
    streamBufferSize the size of the buffer that this array occupies 
    (it depends on how much space is required to store the stream 
    states), and an error code. */
    clrngMrg31k3pStream* streams = clrngMrg31k3pCreateStreams(NULL, numWorkItems,
                               &streamBufferSize, (clrngStatus *)&err);
    //check_error(err, "cannot create random stream array");

    /* Then we create an OpenCL buffer of size streamBufferSize and 
    fill it with a copy of the array of streams, to pass to the device. 
    We also create and pass a buffer that will be used by the device to 
    return an array of numWorkItems values of type cl_double. (OpenCL 
    buffer creation is not specific to clRNG, so it is not discussed 
    here). */
    // Create buffer to transfer streams to the device.
    in_d = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, 
                                    streamBufferSize, streams, &err);
    // Create buffer to transfer output back from the device.
    out_d = clCreateBuffer(context, CL_MEM_WRITE_ONLY | CL_MEM_HOST_READ_ONLY, 
                                     numWorkItems * sizeof(cl_float), out_h, &err);

    /* Kernel setup */
    kernel = clCreateKernel(program, KERNEL_FUNC, &err);
    err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &in_d); 
    err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &out_d); 
    err |= clSetKernelArg(kernel, 2, sizeof(unsigned int), &numWorkItems);
    
    // Get the maximum work group size for executing the kernel on the device
    err = clGetKernelWorkGroupInfo(kernel, device, CL_KERNEL_WORK_GROUP_SIZE, sizeof(localsize), &localsize, NULL);
    // Number of total work items - localSize must be devisor
    globalsize = ceil(numWorkItems/(float)localsize)*localsize;
    printf("global size=%lu, local size=%lu\n", globalsize, localsize);

    /* Enqueue kernel   */
    err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &globalsize, &localsize, 0, NULL, NULL); 
    clFinish(queue);

    /* Read the kernel's output    */
    clEnqueueReadBuffer(queue, out_d, CL_TRUE, 0, numWorkItems*sizeof(float), out_h, 0, NULL, NULL); 

    /* Deallocate resources */
    clReleaseKernel(kernel);
    clReleaseMemObject(in_d);
    clReleaseMemObject(out_d);
    clReleaseCommandQueue(queue);
    clReleaseProgram(program);
    clReleaseContext(context);
    /* End of OpenCL routines ==============================================*/

    printf("Random numbers generated in GPU:\n");
    for (i=0; i<numWorkItems; i++) {
        printf("%f ", out_h[i]);
    }


	return(0);	
}