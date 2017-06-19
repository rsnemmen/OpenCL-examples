/*
 <codex>
 <abstract>
 Utility class for managing cpu bound device and host split position and velocity data.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_SPLIT_DATA_H_
#define _NBODY_SIMULATION_SPLIT_DATA_H_

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
            enum Axis:uint32_t
            {
                eAxisX = 0,
                eAxisY,
                eAxisZ
            };
            
            typedef struct Split3D  *Split3DRef;
            
            class Split
            {
            public:
                Split(const Properties& rProperties);
                
                virtual ~Split();
                
                GLint acquire(cl_context pContext);
                
                GLint bind(const cl_uint& nStartIndex,
                           cl_kernel pKernel);
                
                GLfloat* mass();

                GLfloat* position(const Axis& nCoord);
                GLfloat* velocity(const Axis& nCoord);
                
                const GLfloat* mass() const;

                const GLfloat* position(const Axis& nCoord) const;
                const GLfloat* velocity(const Axis& nCoord) const;
                
            private:
                GLint acquire(const GLuint& nIndex,
                              cl_context pContext);

                Split3DRef  create(const size_t& nCount,
                                   const size_t& nSamples);
                
            private:
                size_t        mnParticles;
                size_t        mnSamples;
                size_t        mnSize;
                cl_mem_flags  mnFlags;
                Split3DRef    mpSplit;
            }; // Split
        } // Data
    } // Simulation
} // NBody

#endif

#endif
