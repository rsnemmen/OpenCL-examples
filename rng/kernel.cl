#include <clRNG/mrg31k3p.clh>

__kernel void example(__global clrngMrg31k3pHostStream* streams, __global float* out) {
    int gid = get_global_id(0);

    clrngMrg31k3pStream private_stream_d;   // This is not a pointer!

    clrngMrg31k3pCopyOverStreamsFromGlobal(1, &private_stream_d, &streams[gid]);

    out[gid] = clrngMrg31k3pRandomU01(&private_stream_d) +
               clrngMrg31k3pRandomU01(&private_stream_d);
}