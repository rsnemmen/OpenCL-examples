/*
 <codex>
 <abstract>
 Utility methods for creating a Gaussian texture.
 </abstract>
 </codex>
 */

#ifndef _OPENGL_UTILITY_GAUSSIAN_H_
#define _OPENGL_UTILITY_GAUSSIAN_H_

#import <OpenGL/OpenGL.h>

#ifdef __cplusplus

namespace GLU
{
    class Gaussian
    {
    public:
        Gaussian(const GLuint& nTexRes = 64);
        
        Gaussian(const Gaussian& rGaussian);

        virtual ~Gaussian();
        
        Gaussian& operator=(const Gaussian& rGaussian);

        void enable();
        void disable();
        
        const GLuint& texture() const;
        const GLenum& target()  const;
    
    private:
        GLuint  mnTexture;
        GLuint  mnTexRes;
        GLenum  mnTarget;
    }; // Gaussian
} // GLU

#endif

#endif

