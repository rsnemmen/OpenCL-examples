/*
 <codex>
 <abstract>
 Functor for copying split position data to/from packed position data.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_DATA_COPIER_H_
#define _NBODY_SIMULATION_DATA_COPIER_H_

#import "NBodySimulationDataPacked.h"
#import "NBodySimulationDataSplit.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            class Copier
            {
            public:
                Copier(const size_t& nCount);
                
                virtual ~Copier();
                
                bool operator()(const Split  * const pSplit,  Packed* pPacked);
                bool operator()(const Packed * const pPacked, Split*  pSplit);
            
            private:
                size_t            mnCount;
                dispatch_queue_t  m_Queue;
            }; // Copier
        } // Data
    } // Simulation
} // NBody

#endif

#endif
