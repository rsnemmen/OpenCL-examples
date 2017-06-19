/*
 <codex>
 <abstract>
 A facade for managing cpu or gpu bound simulators, along with their labeled-button.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_FACADE_H_
#define _NBODY_SIMULATION_FACADE_H_

#import "NBodySimulationBase.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        enum Types
        {
            eComputeCPUSingle = 0,
            eComputeCPUMulti,
            eComputeGPUPrimary,
            eComputeGPUSecondary,
            eComputeMax
        }; // Types

        class Facade
        {
        public:
            Facade(const Types& nType,
                   const Properties& rProperties);
            
            virtual ~Facade();
            
            void start(const bool& paused=true);
            void stop();
            
            void pause();
            void unpause();
                        
            GLfloat* data();
            
            Base* simulator();

            void resetProperties(const Properties& rProperties);
            
            void invalidate(const bool& doInvalidate = true);

            const bool isCPUSingleCore() const;
            const bool isCPUMultiCore()  const;
            const bool isGPUPrimary()    const;
            const bool isGPUSecondary()  const;
            
            const bool isActive()   const;
            const bool isAcquired() const;
            const bool isPaused()   const;
            const bool isStopped()  const;
            
            const GLdouble       performance() const;
            const GLdouble       updates()     const;
            const GLdouble       year()        const;
            const size_t         size()        const;
            const std::string&   label()       const;
            const Types&         type()        const;
            
            void positionInRange(GLfloat *pDst);
            
            void position(GLfloat *pDst);
            void velocity(GLfloat *pDst);
            
            void setRange(const GLint& min,
                          const GLint& max);
            
            void setProperties(const Properties& rProperties);
            
            void setData(const GLfloat * const pData);
            
            void setPosition(const GLfloat * const pSrc);
            void setVelocity(const GLfloat * const pSrc);
            
        private:
            // Acquire a label for the gpu bound simulator
            void setLabel(const GLint& nDevIndex,
                          const GLuint& nDevices,
                          const std::string& rDevice);

            // GPU bound compute
            Base* create(const GLint& nDevIndex,
                         const Properties& rProperties);
            
            // CPU bound compute
            Base* create(const bool& bIsThreaded,
                         const std::string& rLabel,
                         const Properties& rProperties);
            
        private:
            bool         mbIsGPU;
            std::string  m_Label;
            Base*        mpSimulator;
            Types        mnType;
        }; // Facade
    } // Simulation
} // NBody

#endif

#endif
