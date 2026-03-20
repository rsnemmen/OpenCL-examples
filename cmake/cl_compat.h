/*
 * cl_compat.h — OpenCL 1.2/2.0 compatibility shim
 *
 * macOS ships OpenCL 1.2 only.  Several examples use
 * clCreateCommandQueueWithProperties (OpenCL 2.0).  When building on macOS
 * we redirect the call to the deprecated clCreateCommandQueue so that sources
 * remain untouched.
 */
#ifndef CL_COMPAT_H
#define CL_COMPAT_H

#ifdef MAC
#  ifdef clCreateCommandQueueWithProperties
#    undef clCreateCommandQueueWithProperties
#  endif
#  define clCreateCommandQueueWithProperties(ctx, dev, props, err) \
       clCreateCommandQueue((ctx), (dev), 0, (err))
#endif /* MAC */

#endif /* CL_COMPAT_H */
