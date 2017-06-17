#include <cf4ocl2.h>

#define VECSIZE 8
#define SUM_CONST 3

int main() {

    /* Variables. */
    CCLContext * ctx = NULL;
    CCLDevice * dev = NULL;
    CCLQueue * queue = NULL;
    CCLProgram * prg = NULL;
    CCLBuffer * a = NULL, * b = NULL, * c = NULL;
    cl_uint vec_a[VECSIZE] = {0, 1, 2, 3, 4, 5, 6, 7};
    cl_uint vec_b[VECSIZE] = {3, 2, 1, 0, 1, 2, 3, 4};
    cl_uint vec_c[VECSIZE];
    cl_uint d = SUM_CONST;
    size_t gws = VECSIZE;
    cl_bool status;
    CCLEvent * evt = NULL;
    int i;

    /* Create context with user selected device. */
    ctx = ccl_context_new_from_menu(NULL);
    if (ctx == NULL) exit(-1);

    /* Get the selected device. */
    dev = ccl_context_get_device(ctx, 0, NULL);
    if (dev == NULL) exit(-1);

    /* Create a command queue. */
    queue = ccl_queue_new(ctx, dev, 0, NULL);
    if (queue == NULL) exit(-1);

    /* Instantiate and initialize device buffers. */
    a = ccl_buffer_new(ctx, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
        VECSIZE * sizeof(cl_uint), vec_a, NULL);
    if (a == NULL) exit(-1);

    b = ccl_buffer_new(ctx, CL_MEM_READ_ONLY | CL_MEM_COPY_HOST_PTR,
        VECSIZE * sizeof(cl_uint), vec_b, NULL);
    if (b == NULL) exit(-1);

    c = ccl_buffer_new(ctx, CL_MEM_WRITE_ONLY,
        VECSIZE * sizeof(cl_uint), NULL, NULL);
    if (c == NULL) exit(-1);

    /* Create program. */
    prg = ccl_program_new_from_source_file(ctx, "mysum.cl", NULL);
    if (prg == NULL) exit(-1);

    /* Build program. */
    status = ccl_program_build(prg, NULL, NULL);
    if (!status) exit(-1);

    evt = ccl_program_enqueue_kernel(prg, "sum", queue, 1, NULL, &gws,
        NULL, NULL, NULL, a, b, c, ccl_arg_priv(d, cl_uint),
        ccl_arg_priv(gws, cl_uint), NULL);
    if (!evt) exit(-1);

    /* Read the output buffer from the device. */
    evt = ccl_buffer_enqueue_read(c, queue, CL_TRUE, 0,
        VECSIZE * sizeof(cl_uint), vec_c, NULL, NULL);
    if (!evt) exit(-1);

    /* Some OpenCL implementations don't respect the blocking read,
     * so this guarantees that the read is effectively finished. */
    status = ccl_queue_finish(queue, NULL);
    if (!status) exit(-1);

    /* Check for errors. */
    for (i = 0; i < VECSIZE; ++i) {
        if (vec_c[i] != vec_a[i] + vec_b[i] + d) {
            fprintf(stderr, "Unexpected results.\n");
            exit(-1);
        }
    }
    /* No errors found. */
    printf("Results OK!\n");

   /* Destroy cf4ocl wrappers. */
    ccl_program_destroy(prg);
    ccl_buffer_destroy(c);
    ccl_buffer_destroy(b);
    ccl_buffer_destroy(a);
    ccl_queue_destroy(queue);
    ccl_context_destroy(ctx);

    return 0;
}