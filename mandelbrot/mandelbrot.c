#define PROGRAM_FILE "mandelbrot.cl"
#define KERNEL_FUNC "solve_mandelbrot"
#define WG_SIZE 256 // Workgroup size

#include "defs.h"



int main() {

   /* OpenCL structures */
   cl_device_id device;
   cl_context context;
   cl_program program;
   cl_kernel kernel;
   cl_command_queue queue;
   cl_int i, err;
   size_t local_size, global_size;

   /* Data and buffers    */
   // Define Mandelbrot Settings
   int iterations = 2000;
   float x_min  = -2;
   float x_max  =  2;
   float y_min  = -1.5f;
   float y_max  =  1.5f;
   float x_step = .002f;
   float y_step = .002f;

   // Create Linear Vector of Coordinates
   int nreals,nimags;
   float *reals,*imags; // Host input arrays
   int *ans; // Host output array
   nimags=(y_max-y_min)/y_step;
   nreals=(x_max-x_min)/x_step;
   reals = (float *)malloc(sizeof(float)*nreals); 
   imags = (float *)malloc(sizeof(float)*nimags); 
   ans = (int *)malloc(sizeof(int)*nreals); 

   for (i=0; i<nreals; i++) {
      reals[i]=reals[i]+i*x_step;
   }

   for (i=0; i<nimags; i++) {
      imags[i]=imags[i]+i*y_step;
   } 




   // Device input and output buffers
   cl_mem dreals, dimags, dans;

   /* Create device and context   */
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
   dreals = clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(float)*nreals, NULL, NULL);
   dimags = clCreateBuffer(context, CL_MEM_READ_ONLY, sizeof(float)*nimags, NULL, NULL);
   dans = clCreateBuffer(context, CL_MEM_WRITE_ONLY, sizeof(int)*nreals, NULL, NULL);
 
   // Write our data set into the input array in device memory
   err = clEnqueueWriteBuffer(queue, dreals, CL_TRUE, 0, sizeof(float)*nreals, reals, 0, NULL, NULL);
   err |= clEnqueueWriteBuffer(queue, dimags, CL_TRUE, 0, sizeof(float)*nimags, imags, 0, NULL, NULL);

   /* Create a kernel */
   kernel = clCreateKernel(program, KERNEL_FUNC, &err);

   /* Create kernel arguments    */
   err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &dreals); 
   err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &dimags); 
   err |= clSetKernelArg(kernel, 2, sizeof(int), &iterations);
   err |= clSetKernelArg(kernel, 3, sizeof(cl_mem), &dans);

   // Number of work items in each local work group
   local_size = WG_SIZE;
   // Number of total work items - localSize must be devisor
   global_size = ceil(nreals/(float)local_size)*local_size;
   //size_t global_size[3] = {ARRAY_SIZE, 0, 0}; // for 3D data
   //size_t local_size[3] = {WG_SIZE, 0, 0};

   /* Enqueue kernel    */
   err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, &local_size, 0, NULL, NULL); 

   /* Wait for the command queue to get serviced before reading 
   back results */
   clFinish(queue);

   /* Read the kernel's output    */
   clEnqueueReadBuffer(queue, dans, CL_TRUE, 0, sizeof(int)*nreals, ans, 0, NULL, NULL); // <=====GET OUTPUT


   /* Deallocate resources */
   clReleaseKernel(kernel);
   clReleaseMemObject(dreals);
   clReleaseMemObject(dimags);
   clReleaseMemObject(dans);
   clReleaseCommandQueue(queue);
   clReleaseProgram(program);
   clReleaseContext(context);
   return 0;
}
