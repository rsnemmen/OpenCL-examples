/*
 <codex>
 <abstract>
 Utility class for managing cpu bound device and host packed mass and position data.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_PACKED_DATA_H_
#define _NBODY_SIMULATION_PACKED_DATA_H_

#import <vector>

#import <OpenCL/OpenCL.h>

#import "NBodySimulationProperties.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            typedef struct Packed3D* Packed3DRef;
            
            class Packed
            {
            public:
                Packed(const Properties& rProperties);
                
                virtual ~Packed();
                
                GLint acquire(cl_context pContext);
                
                GLint bind(const cl_uint& nIndex,
                           cl_kernel pKernel);
                
                GLint update(const cl_uint& nIndex,
                             cl_kernel pKernel);
                
                GLfloat* data();
                
                const GLfloat* data() const;
                
            private:
                size_t        mnParticles;
                size_t        mnSamples;
                size_t        mnLength;
                size_t        mnSize;
                cl_mem_flags  mnFlags;
                Packed3DRef   mpPacked;
            }; // Packed
        } // Data
    } // Simulation
} // NBody

#endif

#endif
