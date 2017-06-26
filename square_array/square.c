#define PROGRAM_FILE "square.cl"
#define KERNEL_FUNC "square"

#include "defs.h"


int main() {

   /* OpenCL structures */
   cl_device_id device;
   cl_context context;
   cl_program program;
   cl_kernel kernel;
   cl_command_queue queue;
   cl_int i, err;
   long long int ARRAY_SIZE=100000000; // size of arrays
   size_t local_size, global_size;

   /* Data and buffers    */
   // Host input and output vectors
   float *hdata, *houtput;
   // Device input and output buffers
   cl_mem ddata, doutput;

   /* Initialize data */
   // Size, in bytes, of each vector
   size_t bytes = ARRAY_SIZE*sizeof(float);

   // Allocate host arrays
   hdata=(float*)malloc(bytes);
   houtput=(float*)malloc(bytes);

   // Populate input array
   for(i=0; i<ARRAY_SIZE; i++) {
      hdata[i] = 1.0f*i;
   }

   /* Create device and context 

   Creates a context containing only one device — the device structure 
   created earlier.
   */
   device = create_device();
   context = clCreateContext(NULL, 1, &device, NULL, NULL, &err);

   /* Build program */
   program = build_program(context, device, PROGRAM_FILE);

   /* Create a command queue */
   queue = clCreateCommandQueue(context, device, 0, &err);

   /* Create data buffer 
   Create the input and output arrays in device memory for our 
   calculation. 'd' below stands for 'device'.
   */
   ddata = clCreateBuffer(context, CL_MEM_READ_ONLY, bytes, NULL, NULL);
   doutput = clCreateBuffer(context, CL_MEM_WRITE_ONLY, bytes, NULL, NULL);
 
   // Write our data set into the input array in device memory
   err = clEnqueueWriteBuffer(queue, ddata, CL_TRUE, 0,
                                   bytes, hdata, 0, NULL, NULL);

   /* Create a kernel */
   kernel = clCreateKernel(program, KERNEL_FUNC, &err);

   /* Create kernel arguments 
   
   The integers below represent the position of the kernel argument.
   */
   err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &ddata); // <=====INPUT
   err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &doutput); // <=====OUTPUT
   err |= clSetKernelArg(kernel, 2, sizeof(unsigned int), &ARRAY_SIZE);

   /*
   • `global_size`: total number of work items that will be 
      executed on the GPU (e.g. total size of your array)
   • `local_size`: size of local workgroup. Each workgroup contains 
      several work items and goes to a compute unit   

   To map our problem onto the underlying hardware we must specify a 
   local and global integer size. The local size defines the number 
   of work items in a work group, on an NVIDIA GPU this is equivalent 
   to the number of threads in a thread block. The global size is the 
   total number of work items launched. the localSize must be a devisor 
   of globalSize and so we calculate the smallest integer that covers 
   our problem domain and is divisible by localSize.

   Notes: 
   • Intel recommends workgroup size of 64-128. Often 128 is minimum to 
   get good performance on GPU
   • Optimal workgroup size differs across applications
   */
   // Get the maximum work group size for executing the kernel on the device
   err = clGetKernelWorkGroupInfo(kernel, device, CL_KERNEL_WORK_GROUP_SIZE, sizeof(local_size), &local_size, NULL);
   // Number of total work items - localSize must be devisor
   global_size = ceil(ARRAY_SIZE/(float)local_size)*local_size;
   printf("global=%u, local=%u\n", global_size, local_size);
   //size_t global_size[3] = {ARRAY_SIZE, 0, 0}; // for 3D data
   //size_t local_size[3] = {WG_SIZE, 0, 0};

   /* Enqueue kernel 

   At this point, the application has created all the data structures 
   (device, kernel, program, command queue, and context) needed by an 
   OpenCL host application. Now, it deploys the kernel to a device.

   Of the OpenCL functions that run on the host, clEnqueueNDRangeKernel 
   is probably the most important to understand. Not only does it deploy 
   kernels to devices, it also identifies how many work-items should 
   be generated to execute the kernel (global_size) and the number of 
   work-items in each work-group (local_size).

   clEnqueueNDRangeKernel args:
   3. Number of dimensions of the argument
   5. global size of data that will be handled. If you were dealing with a
      2D image, you would use: 
      size_t global[3] = {nx, ny, 0}
      err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, global, 
         &local_size, 0, NULL, NULL); 
   */
   err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, &local_size, 0, NULL, NULL); 
   //clEnqueueNDRangeKernel(queue, kernel, 1, NULL, global_size, local_size, 0, NULL, NULL); 

   /* Wait for the command queue to get serviced before reading 
   back results */
   clFinish(queue);

   /* Read the kernel's output    */
   clEnqueueReadBuffer(queue, doutput, CL_TRUE, 0, bytes, houtput, 0, NULL, NULL); // <=====GET OUTPUT

   /* Check result */
   /*for (i=0; i<ARRAY_SIZE; i++) {
      printf("%f ", houtput[i]);
   } */

   /* Deallocate resources */
   clReleaseKernel(kernel);
   clReleaseMemObject(ddata);
   clReleaseMemObject(doutput);
   clReleaseCommandQueue(queue);
   clReleaseProgram(program);
   clReleaseContext(context);
   return 0;
}
