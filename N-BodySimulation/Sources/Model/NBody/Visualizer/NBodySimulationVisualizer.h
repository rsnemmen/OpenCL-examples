/*
 <codex>
 <abstract>
 A Visualizer mediator object for managing of rendering n-particles to an OpenGL view.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_VISUALIZER_H_
#define _NBODY_SIMULATION_VISUALIZER_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <simd/simd.h>

#import "GLUGaussian.h"
#import "GLUProgram.h"
#import "GLUTexture.h"

#import "NBodySimulationProperties.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class Visualizer
        {
        public:
            Visualizer(const Properties& rProperties);
            
            virtual ~Visualizer();
            
            void reset(const GLuint& nDemo);
            
            void draw(const GLfloat *pPosition);
            
            const bool isValid() const;
            
            const simd::float3& eye() const;
            
            void stopRotation();
            void toggleRotation();
            
            void toggleEarthView();
            
            void setFrame(const CGSize& rFrame);
            
            void setIsResetting(const bool& bReset);
            void setShowEarthView(const bool& bShowView);
            
            void setRotation(const CGPoint& rRotation);
            void setRotationChange(const GLfloat& nDelta);
            void setRotationSpeed(const GLfloat& nSpeed);
            
            void setTimeScale(const GLfloat& nScale);
            
            void setStarSize(const GLfloat& nSize);
            void setStarScale(const GLfloat& nScale);
            
            void setViewDistance(const GLfloat& nDistance);
            void setViewRotation(const CGPoint& rRotation);
            void setViewTime(const GLfloat& nTime);
            void setViewZoom(const GLfloat& nZoom);
            void setViewZoomSpeed(const GLfloat& nSpeed);
            
            bool setProperties(const GLuint& nCount,
                               const Properties * const pProperties);
            
        public:
            simd::float3 m_Center;
            simd::float3 m_Up;
            
        private:
            bool buffer(const GLuint& nCount);
            bool textures(CFStringRef pName, CFStringRef pExt, const GLint& nTexRes = 32);
            bool program(CFStringRef pName);
            
            bool acquire(const Properties& rProperties);
            
            void lookAt(const GLfloat *pPosition);
            void projection();
            
            void render(const GLfloat *pPosition);
            void update();
            
            void advance(const GLuint& nDemo);
            
        private:
            bool  m_Flag[4];
            
            simd::float3 m_Eye;
            
            simd::float4x4 m_ModelView;
            simd::float4x4 m_Projection;
            
            CGPoint m_ViewRotation;
            CGPoint m_Rotation;
            CGSize  m_Frame;
            
            GLsizei  m_Bounds[2];
            GLfloat  m_Property[9];
            GLuint   m_Graphic[5];
            GLuint   mnActiveDemo;
            int64_t  mnCount;
            
            Properties*  mpProperties;
            
            GLU::Program*  mpProgram;
            GLU::Gaussian* mpGausssian;
            GLU::Texture*  mpTexture;
        }; // Visualizer
    } // SImulation
} // NBody

#endif

#endif
