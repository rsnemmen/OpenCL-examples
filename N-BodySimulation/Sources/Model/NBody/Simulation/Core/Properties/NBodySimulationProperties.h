/*
 <codex>
 <abstract>
 N-Body simulation Properties.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_PROPERTIES_H_
#define _NBODY_SIMULATION_PROPERTIES_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "NBodyPreferences.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {        
        class Properties
        {
        public:
            Properties(const uint32_t& demoType = 1);
            Properties(NSDictionary* pDictionary);
            Properties(NBodyPreferences* pPreferences);
            
            Properties(const Properties& rProperties);

            virtual ~Properties();

            Properties& operator=(const Properties& rProperties);
            Properties& operator=(NSDictionary* pDictionary);
            Properties& operator=(NBodyPreferences* pPreferences);
            
            NSDictionary*   dictionary();

            void update(NBodyPreferences* pPreferences);
            
            static Properties* create(const size_t& nCount);

            static Properties* create();
            static Properties* create(NSString* pFilename);
            
        public:
            bool      mbIsGPUOnly;
            int64_t   mnDemos;
            uint32_t  mnDemoType;
            uint32_t  mnParticles;
            uint32_t  mnConfig;
            float     mnTimeStep;
            float     mnClusterScale;
            float     mnVelocityScale;
            float     mnSoftening;
            float     mnDamping;
            float     mnPointSize;
            float     mnViewDistance;
            double    mnRotateX;
            double    mnRotateY;
        }; // Properties
    } // Simulation
} // NBody

#endif

#endif
