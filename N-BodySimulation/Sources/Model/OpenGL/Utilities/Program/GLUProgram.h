/*
 <codex>
 <abstract>
 Utility method for creating an OpenGL program object.
 </abstract>
 </codex>
 */

#ifndef _OPENGL_UTILITY_PROGRAM_H_
#define _OPENGL_UTILITY_PROGRAM_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "GLcontainers.h"

#ifdef __cplusplus

namespace GLU
{
    class Program
    {
    public:
        Program(CFStringRef pName);
        
        Program(CFStringRef     pName,
                const GLenum&   inType,
                const GLenum&   outType,
                const GLsizei&  vertOut);
        
        Program(const Program& rProgram);
        
        virtual ~Program();
        
        Program& operator=(const Program& rProgram);

        void enable();
        void disable();
        
        const GLuint& program() const;
        
    private:
        GLuint     mnProgram;
        GLenum     mnInType;
        GLenum     mnOutType;
        GLsizei    mnOutVert;
        GLsources  m_Sources;
    }; // Program
} // GLU

#endif

#endif

