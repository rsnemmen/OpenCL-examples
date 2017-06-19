/*
 <codex>
 <abstract>
 Utility class for managing gpu bound computes for n-body simulation.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_GPU_H_
#define _NBODY_SIMULATION_GPU_H_

#import <OpenCL/OpenCL.h>

#import "NBodySimulationBase.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class GPU : public Base
        {
        public:
            GPU(const Properties& rProperties,
                const GLuint& nIndex = 0);
            
            virtual ~GPU();
            
            void initialize(const std::string& options);
            
            GLint reset();
            void  step();
            void  terminate();
            
            GLint positionInRange(GLfloat *pDst);
            
            GLint position(GLfloat *pDst);
            GLint velocity(GLfloat *pDst);
            
            GLint setPosition(const GLfloat * const pSrc);
            GLint setVelocity(const GLfloat * const pSrc);
            
        private:
            GLint setup(const std::string& options);
            
            GLint bind();
            GLint execute();
            GLint restart();
            
        private:
            bool              mbTerminated;
            GLfloat*          mpHostPosition;
            GLfloat*          mpHostVelocity;
            GLuint            mnReadIndex;
            GLuint            mnWriteIndex;
            GLuint            mnWorkItemX;
            GLint             mnDeviceIndex;
            cl_context        mpContext;
            cl_program        mpProgram;
            cl_kernel         mpKernel;
            cl_device_id      mpDevice[2];
            cl_command_queue  mpQueue[2];
            cl_mem            mpDevicePosition[2];
            cl_mem            mpDeviceVelocity[2];
            cl_mem            mpBodyRangeParams;
        }; // GPU
    } // Simulation
} // NBody

#endif

#endif
