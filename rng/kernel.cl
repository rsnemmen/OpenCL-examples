/* 
Pointers to the global memory buffers received from the host and to 
the output array are passed to the kernel as arguments. (The correspondence 
between the kernel arguments and the buffers on the host is specified in 
the host code, not shown here). 

For each work item, we create a private 
copy of its stream, named private_stream, in its private memory, so we can 
generate random numbers on the device. The private memory must be allocated 
at compile time; this is why private_stream is not declared as a pointer, so 
the declaration allocates memory. The kernel just generates two random numbers 
and returns the sum, in a cl_double.
*/


#include <clRNG/mrg31k3p.clh>

__kernel void example(__global clrngMrg31k3pHostStream* streams, __global float* out, const int n) {
    int gid = get_global_id(0);

	if (gid<n) {
    	clrngMrg31k3pStream private_stream_d;   // This is not a pointer!

    	clrngMrg31k3pCopyOverStreamsFromGlobal(1, &private_stream_d, &streams[gid]);

    	out[gid] = clrngMrg31k3pRandomU01(&private_stream_d);
    	printf("%f\n",out[gid]);
    }
}