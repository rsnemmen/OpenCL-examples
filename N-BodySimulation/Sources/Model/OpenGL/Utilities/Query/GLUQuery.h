/*
 <codex>
 <abstract>
 Utility class for querying OpenGL for vendor, version, and renderer.
 </abstract>
 </codex>
 */

#ifndef _OPENGL_UTILITY_QUERY_H_
#define _OPENGL_UTILITY_QUERY_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "GLcontainers.h"

#ifdef __cplusplus

namespace GLU
{
    class Query
    {
    public:
        Query();
        
        virtual ~Query();
        
        const bool match(GLstring& rKey)   const;
        const bool match(GLstrings& rKeys) const;
        
        const GLstring& info()     const;
        const GLstring& renderer() const;
        const GLstring& vendor()   const;
        const GLstring& version()  const;
        
        const bool& isAMD()    const;
        const bool& isATI()    const;
        const bool& isNVidia() const;
        const bool& isIntel()  const;
        
    private:
        const bool match(const GLuint& i, const GLuint& j) const;
        const bool match(const GLstring& expr) const;
        
        GLstring createString(const GLenum& name);
        
    private:
        bool      m_Flag[4];
        GLregex   m_Regex[4];
        GLstring  m_String[4];
    }; // Query
} // GLU

#endif

#endif
