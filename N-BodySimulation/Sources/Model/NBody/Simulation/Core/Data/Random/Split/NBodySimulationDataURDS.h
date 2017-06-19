/*
 <codex>
 <abstract>
 Functor for generating random split-data sets for the cpu or gpu bound simulator using uniform random distribution.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_DATA_URDS_H_
#define _NBODY_SIMULATION_DATA_URDS_H_

#import "NBodySimulationDataURDB.h"
#import "NBodySimulationDataSplit.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            class URDS : public URDB
            {
            public:
                URDS(const Properties& rProperties);
                
                virtual ~URDS();
                                
                bool operator()(Split* pSplit);
                                
            private:
                void configRandom();
                void configShell();
                void configMWM31();
                void configExpand();

                GLfloat mnCount;
                GLfloat mnBCScale;
                
                GLfloat* mpMass;
                GLfloat* mpPosition[3];
                GLfloat* mpVelocity[3];
            }; // URDS
        } // Data
    } // Simulation
} // NBody

#endif

#endif
