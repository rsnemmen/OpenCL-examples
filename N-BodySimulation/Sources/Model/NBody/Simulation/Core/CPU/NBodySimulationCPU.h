/*
 <codex>
 <abstract>
 Utility class for managing cpu bound computes for n-body simulation.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_CPU_H_
#define _NBODY_SIMULATION_CPU_H_

#import <OpenCL/OpenCL.h>

#import "NBodySimulationDataMediator.h"
#import "NBodySimulationBase.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class CPU : public Base
        {
        public:
            CPU(const Properties& properties,
                const bool& vectorized,
                const bool& threaded = true);
            
            virtual ~CPU();
            
            void initialize(const std::string& options);
            
            GLint reset();
            void  step();
            void  terminate();
            
            GLint positionInRange(GLfloat* pDst);
            
            GLint position(GLfloat* pDst);
            GLint velocity(GLfloat* pDst);
            
            GLint setPosition(const GLfloat * const pSrc);
            GLint setVelocity(const GLfloat * const pSrc);
            
        private:
            GLint setup(const std::string& options,
                        const bool& vectorized,
                        const bool& threaded = true);
            
            GLint bind();
            GLint execute();
            GLint restart();
            
        private:
            bool              mbVectorized;
            bool              mbThreaded;
            bool              mbTerminated;
            GLuint            mnUnits;
            cl_device_id      mpDevice;
            cl_command_queue  mpQueue;
            cl_context        mpContext;
            cl_program        mpProgram;
            cl_kernel         mpKernel;
            Data::Mediator*   mpData;
        }; // CPU
    } // Simulation
} // NBody

#endif

#endif
