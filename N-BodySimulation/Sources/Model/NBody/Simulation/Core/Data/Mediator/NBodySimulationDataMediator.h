/*
 <codex>
 <abstract>
 Utility class for managing cpu bound device and host memories.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_DATA_H_
#define _NBODY_SIMULATION_DATA_H_

#import <OpenCL/OpenCL.h>

#import "NBodySimulationProperties.h"
#import "NBodySimulationDataPacked.h"
#import "NBodySimulationDataSplit.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            class Mediator
            {
            public:
                Mediator(const Properties& rProperties);
                
                virtual ~Mediator();
                
                void swap();
                
                GLint acquire(cl_context pContext);
                GLint bind(cl_kernel pKernel);
                GLint update(cl_kernel pKernel);
                
                void reset(const Properties& rProperties);
                
                GLint positionInRange(const CFRange& range,
                                      GLfloat* pDst);

                GLint positionInRange(const size_t& nMin,
                                      const size_t& nMax,
                                      GLfloat* pDst);
                
                GLint position(const size_t& nMax,
                               GLfloat* pDst);
                
                GLint velocity(GLfloat* pDst);
                
                GLint setPosition(const GLfloat * const pSrc);
                GLint setVelocity(const GLfloat * const pSrc);
                
                const GLfloat* data() const;
                
            private:
                GLuint            mnReadIndex;
                GLuint            mnWriteIndex;
                size_t            mnParticles;
                Packed*           mpPacked;
                Split*            mpSplit[2];
                dispatch_queue_t  m_Queue;
            }; // Mediator
        } // Data
    } // Simulation
} // NBody

#endif

#endif
