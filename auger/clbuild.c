#include "defs.h"

/* Find a GPU or CPU associated with the first available platform 

The `platform` structure identifies the first platform identified by the 
OpenCL runtime. A platform identifies a vendor's installation, so a system 
may have an NVIDIA platform and an AMD platform. 

The `device` structure corresponds to the first accessible device 
associated with the platform. Because the second parameter is 
`CL_DEVICE_TYPE_GPU`, this device must be a GPU.
*/
cl_device_id create_device(const int gpu) {

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
   if (gpu==1) {
      // GPU
      err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &dev, NULL);
      if(err == CL_DEVICE_NOT_FOUND) {
         // CPU
         err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_CPU, 1, &dev, NULL);
      }
   } else {
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
   err = clBuildProgram(program, 0, NULL,"-I /usr/local/include", NULL, NULL);
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


/* 
Checks whether there was an error in the execution of the
corresponding OpenCL task.

- err: error variable
- c: error message to display
*/
void error_check(cl_int err, char *c) {
   if(err < 0) {
      perror(c);
      exit(1);   
   };


}

