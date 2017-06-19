/*
 <codex>
 <abstract>
 Utility base class defining interface for the derived classes, as well as,
 performing thread and mutex mangement, and managment of meter arrays.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_BASE_H_
#define _NBODY_SIMULATION_BASE_H_

#import <pthread.h>

#import <string>

#import <OpenGL/OpenGL.h>

#import "NBodyConstants.h"
#import "NBodySimulationProperties.h"

#import "HUDMeterTimer.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class Base
        {
        public:
            Base(const Properties& Properties);
            
            virtual ~Base();
            
            virtual void initialize(const std::string& options) = 0;
            
            virtual GLint reset()     = 0;
            virtual void  step()      = 0;
            virtual void  terminate() = 0;
            
            virtual GLint positionInRange(GLfloat *pDst) = 0;
            
            virtual GLint position(GLfloat *pDst) = 0;
            virtual GLint velocity(GLfloat *pDst) = 0;
            
            virtual GLint setPosition(const GLfloat * const pSrc) = 0;
            virtual GLint setVelocity(const GLfloat * const pSrc) = 0;
                        
            void start(const bool& paused=true);
            void stop();
            
            void pause();
            void unpause();
            
            void exit();
            
            const bool isAcquired() const;
            const bool isPaused()   const;
            const bool isStopped()  const;
            
            const GLdouble&     performance() const;
            const GLdouble&     updates()     const;
            const GLdouble&     year()        const;
            const size_t&       size()        const;
            const size_t&       minimum()     const;
            const size_t&       maximum()     const;
            const std::string&  name()        const;
            const GLuint&       devices()     const;
            
            void resetProperties(const Properties& Properties);
            void setProperties(const Properties& Properties);
            
            void setRange(const GLint& min,
                          const GLint& max);
                          
            void invalidate(const bool& v = true);
            
            void setData(const GLfloat * const pData);
            
            GLfloat *data();
            
        private:
            
            void run();
            
            friend void *simulate(void *arg);
            
        protected:
            
            bool mbAcquired;
            bool mbIsUpdated;
            
            GLuint  mnDeviceCount;
            GLuint  mnDevices;
            
            size_t  mnLength;
            size_t  mnSamples;
            size_t  mnSize;
            size_t  mnMinIndex;
            size_t  mnMaxIndex;
            
            std::string  m_DeviceName;
            
            Properties m_Properties;
            
        private:
            
            bool  mbStop;
            bool  mbReload;
            bool  mbPaused;
            bool  mbKeepAlive;
            
            std::string         m_Options;
            
            void * volatile     mpData;
            
            pthread_t           m_Thread;
            pthread_mutex_t     m_RunLock;
            pthread_mutexattr_t m_RunAttrib;
            pthread_mutex_t     m_ClockLock;
            pthread_mutexattr_t m_ClockAttrib;
            
            HUD::Meter::Timer   m_Timer;
            GLdouble            mnTime;
            
            HUD::Meter::Timer   m_Updates;
            GLdouble            mnUpdates;
            
            GLdouble            mnYear;
            GLdouble            mnFreq;
            GLdouble            mnDelta;
            size_t              mnCardinality;
        }; // Base
    } // Simulation
} // NBody

#endif

#endif
