__kernel void sum(__global const uint *a, __global const uint *b,
	__global uint * c, uint d, uint buf_size) {

	/* Get global ID. */
	uint gid = get_global_id(0);

	/* Only perform sum if this workitem is within the size of the
	 * vector. */
	if (gid < buf_size)
		c[gid] = a[gid] + b[gid] + d;
}