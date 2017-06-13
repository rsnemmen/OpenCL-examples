#define PROGRAM_FILE "square.cl"
#define KERNEL_FUNC "square"
#define ARRAY_SIZE 100000
#define MAX_CUS 40 // Max number of GPU compute units

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef MAC
#include <OpenCL/cl.h>
#else
#include <CL/cl.h>
#endif

/* Find a GPU or CPU associated with the first available platform 

The `platform` structure identifies the first platform identified by the 
OpenCL runtime. A platform identifies a vendor's installation, so a system 
may have an NVIDIA platform and an AMD platform. 

The `device` structure corresponds to the first accessible device 
associated with the platform. Because the second parameter is 
`CL_DEVICE_TYPE_GPU`, this device must be a GPU.
*/
cl_device_id create_device() {

   cl_platform_id platform;
   cl_device_id dev;
   int err;

   /* Identify a platform */
   err = clGetPlatformIDs(1, &platform, NULL);
   if(err < 0) {
      perror("Couldn't identify a platform");
      exit(1);
   } 

   // Access a device
   // GPU
   err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &dev, NULL);
   if(err == CL_DEVICE_NOT_FOUND) {
      // CPU
      err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_CPU, 1, &dev, NULL);
   }
   if(err < 0) {
      perror("Couldn't access any devices");
      exit(1);   
   }

   return dev;
}





/* Create program from a file and compile it */
cl_program build_program(cl_context ctx, cl_device_id dev, const char* filename) {

   cl_program program;
   FILE *program_handle;
   char *program_buffer, *program_log;
   size_t program_size, log_size;
   int err;

   /* Read program file and place content into buffer */
   program_handle = fopen(filename, "r");
   if(program_handle == NULL) {
      perror("Couldn't find the program file");
      exit(1);
   }
   fseek(program_handle, 0, SEEK_END);
   program_size = ftell(program_handle);
   rewind(program_handle);
   program_buffer = (char*)malloc(program_size + 1);
   program_buffer[program_size] = '\0';
   fread(program_buffer, sizeof(char), program_size, program_handle);
   fclose(program_handle);

   /* Create program from file 

   Creates a program from the source code in the add_numbers.cl file. 
   Specifically, the code reads the file's content into a char array 
   called program_buffer, and then calls clCreateProgramWithSource.
   */
   program = clCreateProgramWithSource(ctx, 1, 
      (const char**)&program_buffer, &program_size, &err);
   if(err < 0) {
      perror("Couldn't create the program");
      exit(1);
   }
   free(program_buffer);

   /* Build program 

   The fourth parameter accepts options that configure the compilation. 
   These are similar to the flags used by gcc. For example, you can 
   define a macro with the option -DMACRO=VALUE and turn off optimization 
   with -cl-opt-disable.
   */
   err = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
   if(err < 0) {

      /* Find size of log and print to std output */
      clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, 
            0, NULL, &log_size);
      program_log = (char*) malloc(log_size + 1);
      program_log[log_size] = '\0';
      clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, 
            log_size + 1, program_log, NULL);
      printf("%s\n", program_log);
      free(program_log);
      exit(1);
   }

   return program;
}





int main() {

   /* OpenCL structures */
   cl_device_id device;
   cl_context context;
   cl_program program;
   cl_kernel kernel;
   cl_command_queue queue;
   cl_int i, j, err;
   size_t local_size, global_size;

   /* Data and buffers    */
   float data[ARRAY_SIZE], output[ARRAY_SIZE];
   cl_mem input_buffer, out_buffer;
   cl_int num_groups; // number of workgroups

   /* Initialize data */
   for(i=0; i<ARRAY_SIZE; i++) {
      data[i] = 1.0f*i;
   }

   /* Create device and context 

   Creates a context containing only one device — the device structure 
   created earlier.
   */
   device = create_device();
   context = clCreateContext(NULL, 1, &device, NULL, NULL, &err);
   if(err < 0) {
      perror("Couldn't create a context");
      exit(1);   
   }

   /* Build program */
   program = build_program(context, device, PROGRAM_FILE);

   /* Create data buffer 

   • `global_size`: total number of work items that will be 
      executed on the GPU (e.g. total size of your array)
   • `local_size`: size of local workgroup. Each workgroup contains 
      several work items and goes to a compute unit 

   In this example, the kernel is executed by eight work-items divided into 
   two work-groups of four work-items each. Returning to my analogy, 
   this corresponds to a school containing eight students divided into 
   two classrooms of four students each.   

     Notes: 
   • Intel recommends workgroup size of 64-128. Often 128 is minimum to 
   get good performance on GPU
   • On NVIDIA Fermi, workgroup size must be at least 192 for full 
   utilization of cores
   • Optimal workgroup size differs across applications
   */
   global_size = ARRAY_SIZE;
   //local_size = 4; 
   //num_groups = global_size/local_size;
   input_buffer = clCreateBuffer(context, CL_MEM_READ_ONLY |
         CL_MEM_COPY_HOST_PTR, ARRAY_SIZE * sizeof(float), data, &err); // <=====INPUT
   out_buffer = clCreateBuffer(context, CL_MEM_READ_WRITE |
         CL_MEM_COPY_HOST_PTR, ARRAY_SIZE * sizeof(float), output, &err); // <=====OUTPUT
   if(err < 0) {
      perror("Couldn't create a buffer");
      exit(1);   
   };

   /* Create a command queue 

   Does not support profiling or out-of-order-execution
   */
   queue = clCreateCommandQueue(context, device, 0, &err);
   if(err < 0) {
      perror("Couldn't create a command queue");
      exit(1);   
   };

   /* Create a kernel */
   kernel = clCreateKernel(program, KERNEL_FUNC, &err);
   if(err < 0) {
      perror("Couldn't create a kernel");
      exit(1);
   };

   /* Create kernel arguments 
   
   The integers below represent the position of the kernel argument.
   */
   err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &input_buffer); // <=====INPUT
   err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &out_buffer); // <=====OUTPUT
   if(err < 0) {
      perror("Couldn't create a kernel argument");
      exit(1);
   }

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
   //err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, &local_size, 0, NULL, NULL); 
   err = clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &global_size, NULL, 0, NULL, NULL); 
   if(err < 0) {
      perror("Couldn't enqueue the kernel");
      exit(1);
   }

   /* Read the kernel's output    */
   err = clEnqueueReadBuffer(queue, out_buffer, CL_TRUE, 0, 
         sizeof(output), output, 0, NULL, NULL); // <=====GET OUTPUT
   if(err < 0) {
      perror("Couldn't read the buffer");
      exit(1);
   }

   /* Check result 
   for (i=0; i<ARRAY_SIZE; i++) {
      printf("%f\n", output[i]);
   } */

   /* Deallocate resources */
   clReleaseKernel(kernel);
   clReleaseMemObject(out_buffer);
   clReleaseMemObject(input_buffer);
   clReleaseCommandQueue(queue);
   clReleaseProgram(program);
   clReleaseContext(context);
   return 0;
}
