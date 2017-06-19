/*
 <codex>
 <import>GLUQuery.h</import>
 </codex>
 */

#import <OpenGL/gl.h>

#import "GLUQuery.h"

#pragma mark -
#pragma mark Private - Enumerated Types

enum GLUQueryStrings
{
    eGLUQueryRenderer = 0,
    eGLUQueryVendor,
    GLUQueryVersion,
    eGLUQueryInfo
};

typedef enum GLUQueryStrings GLUQueryStrings;

enum GLUQueryVendors
{
    eGLUQueryIsAMD = 0,
    eGLUQueryIsATI,
    eGLUQueryIsNVidia,
    eGLUQueryIsIntel
};

typedef enum GLUQueryVendors GLUQueryVendors;

#pragma mark -
#pragma mark Private - Utilities

GLstring GLU::Query::createString(const GLenum& name)
{
	const char *pString = (const char *)glGetString(name);
	
    return GLstring(pString);
} // createString

const bool GLU::Query::match(const GLuint& i, const GLuint& j) const
{
    return std::regex_match(m_String[i], m_Regex[j]);
} // match

#pragma mark -
#pragma mark Public - Constructor

GLU::Query::Query()
{
    m_String[eGLUQueryRenderer] = createString(GL_RENDERER);
    m_String[eGLUQueryVendor]   = createString(GL_VENDOR);
    m_String[GLUQueryVersion]   = createString(GL_VERSION);
    
    m_String[eGLUQueryInfo] =
    m_String[eGLUQueryRenderer] + "\n"
    +   m_String[eGLUQueryVendor]   + "\n"
    +   m_String[GLUQueryVersion];
    
    m_Regex[eGLUQueryIsAMD]    = GLregex("AMD|amd");
    m_Regex[eGLUQueryIsATI]    = GLregex("ATI|ati");
    m_Regex[eGLUQueryIsNVidia] = GLregex("NVIDIA|nVidia|NVidia|nvidia");
    m_Regex[eGLUQueryIsIntel]  = GLregex("Intel|intel|INTEL");
    
    m_Flag[eGLUQueryIsAMD]    = match(eGLUQueryVendor, eGLUQueryIsAMD);
    m_Flag[eGLUQueryIsATI]    = match(eGLUQueryVendor, eGLUQueryIsATI);
    m_Flag[eGLUQueryIsNVidia] = match(eGLUQueryVendor, eGLUQueryIsNVidia);
    m_Flag[eGLUQueryIsIntel]  = match(eGLUQueryVendor, eGLUQueryIsIntel);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

GLU::Query::~Query()
{
    m_String[eGLUQueryRenderer].clear();
    m_String[eGLUQueryVendor].clear();
    m_String[GLUQueryVersion].clear();
    m_String[eGLUQueryInfo].clear();
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLstring& GLU::Query::info() const
{
    return m_String[eGLUQueryInfo];
} // info

const GLstring& GLU::Query::renderer() const
{
    return m_String[eGLUQueryRenderer];
} // renderer

const GLstring& GLU::Query::vendor() const
{
    return m_String[eGLUQueryVendor];
} // vendor

const GLstring& GLU::Query::version() const
{
    return m_String[GLUQueryVersion];
} // version

#pragma mark -
#pragma mark Public - Queries

const bool& GLU::Query::isAMD() const
{
    return m_Flag[eGLUQueryIsAMD];
} // isAMD

const bool& GLU::Query::isATI() const
{
    return m_Flag[eGLUQueryIsATI];
} // isATI

const bool& GLU::Query::isNVidia() const
{
    return m_Flag[eGLUQueryIsNVidia];
} // isNVidia

const bool& GLU::Query::isIntel() const
{
    return m_Flag[eGLUQueryIsIntel];
} // isIntel

const bool GLU::Query::match(GLstring& rKey) const
{
    bool bSuccess = !rKey.empty();
    
    if(bSuccess)
    {
        std::size_t found = m_String[eGLUQueryRenderer].find(rKey);
        
        bSuccess = found != std::string::npos;
    } // if
    
    return bSuccess;
} // match

const bool GLU::Query::match(GLstrings& rKeys) const
{
    bool bSuccess = !rKeys.empty();
    
    if(bSuccess)
    {
        GLstring expr;
        
        size_t i;
        size_t iMax = rKeys.size() - 1;
        
        for(i = 0; i < iMax; ++i)
        {
            expr += rKeys[i] + "|";
        } // for
        
        expr += rKeys[iMax];
        
        GLregex regex(expr);
        
        bSuccess = std::regex_match(m_String[eGLUQueryRenderer], regex);
    } // if
    
    return bSuccess;
} // isFound

