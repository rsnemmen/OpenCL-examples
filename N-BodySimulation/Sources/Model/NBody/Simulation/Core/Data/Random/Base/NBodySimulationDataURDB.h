/*
 <codex>
 <abstract>
 Base class for generating random packed or split data sets for the cpu or gpu bound simulator using unifrom random distributuon.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_DATA_URD_BASE_H_
#define _NBODY_SIMULATION_DATA_URD_BASE_H_

#import <OpenGL/OpenGL.h>

#import "CMRandom.h"

#import "NBodySimulationProperties.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            class URDB
            {
            public:
                URDB(const Properties& rProperties);
                
                virtual ~URDB();
                
                const simd::float3& axis() const;

                void setAxis(const simd::float3& axis);

                void setProperties(const Properties& rProperties);
                
            protected:
                size_t               mnParticles;
                GLuint               mnConfig;
                GLfloat              m_Scale[2];
                simd::float3         m_Axis;
                dispatch_queue_t     m_DQueue;
                CM::URD3::generator* mpGenerator[2];
            }; // URD Base
        } // Random
    } // Simulation
} // NBody

#endif

#endif
