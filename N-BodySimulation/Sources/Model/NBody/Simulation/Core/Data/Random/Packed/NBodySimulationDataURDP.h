/*
 <codex>
 <abstract>
 Functor for generating random packed-data sets for the cpu or gpu bound simulator using uniform random distribution.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_DATA_URDP_H_
#define _NBODY_SIMULATION_DATA_URDP_H_

#import "NBodySimulationDataURDB.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            class URDP : public URDB
            {
            public:
                URDP(const Properties& rProperties);
                
                virtual ~URDP();
                
                bool operator()(GLfloat* pPosition, GLfloat* pVelocity);
                
            private:
                void configRandom(simd::float4* pPosition, simd::float4* pVelocity);
                void configShell(simd::float4* pPosition, simd::float4* pVelocity);
                void configMWM31(simd::float4* pPosition, simd::float4* pVelocity);
                void configExpand(simd::float4* pPosition, simd::float4* pVelocity);
                
                GLfloat mnCount;
                GLfloat mnBCScale;
                GLfloat mnTCScale;
                GLfloat mnVCScale;
            }; // URDP
        } // Data
    } // Simulation
} // NBody

#endif

#endif
