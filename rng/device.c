/* 
Taken from http://clmathlibraries.github.io/clRNG/htmldocs/index.html.
*/

#define PROGRAM_FILE "kernel.cl"
#define KERNEL_FUNC "example"

#include <clRNG/mrg31k3p.h>

int main(int argc, char *argv[]) {

    size_t streamBufferSize;
    clrngMrg31k3pStream* streams = clrngMrg31k3pCreateStreams(NULL, numWorkItems,
                               &streamBufferSize, (clrngStatus *)&err);
    check_error(err, "cannot create random stream array");

    // Create buffer to transfer streams to the device.
    cl_mem buf_in = clCreateBuffer(context, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR, 
                                    streamBufferSize, streams, &err);
    // Create buffer to transfer output back from the device.
    cl_mem buf_out = clCreateBuffer(context, CL_MEM_WRITE_ONLY | CL_MEM_HOST_READ_ONLY, 
                                     numWorkItems * sizeof(cl_float), NULL, &err);

	return(0);	
}