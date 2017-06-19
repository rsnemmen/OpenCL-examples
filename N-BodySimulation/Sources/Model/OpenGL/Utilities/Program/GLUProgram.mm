/*
 <codex>
 <import>GLUProgram.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <iostream>
#import <string>

#import <OpenGL/gl.h>

#import "CFFile.h"

#import "GLUProgram.h"

#pragma mark -
#pragma mark Private - Utilities - Shaders

static GLstring GLUShaderSourceCreate(const GLenum& target,
                                      CFStringRef pName)
{
    CFStringRef pExt = nullptr;
    GLstring    shader;
    
    switch(target)
    {
        case GL_VERTEX_SHADER:
            pExt   = CFSTR("vsh");
            shader = "vertex";
            break;
            
        case GL_GEOMETRY_SHADER_EXT:
            pExt   = CFSTR("gsh");
            shader = "geometry";
            break;
            
        case GL_FRAGMENT_SHADER:
            pExt   = CFSTR("fsh");
            shader = "fragment";
            break;
            
        default:
            break;
    } // switch
    
    CF::File file(pName, pExt);
    
    return file.string();
} // GLUShaderSourceCreate

static GLsources GLUShaderSourcesCreate(const GLtargets& targets,
                                        CFStringRef pName)
{
    GLsources sources;
    
    for(auto& target:targets)
    {
        GLstring source = GLUShaderSourceCreate(target, pName);
        
        if(!source.empty())
        {
            sources.emplace(target, source);
        } // if
    } // for
    
    return sources;
} // GLUShaderSourcesCreate

static void GLUShaderGetInfoLog(const GLuint& nShader)
{
    GLint nInfoLogLength = 0;
    
    glGetShaderiv(nShader, GL_INFO_LOG_LENGTH, &nInfoLogLength);
    
    if(nInfoLogLength)
    {
        GLchar* pInfoLog = new (std::nothrow) GLchar[nInfoLogLength];
        
        if(pInfoLog != nullptr)
        {
            glGetShaderInfoLog(nShader,
                               nInfoLogLength,
                               &nInfoLogLength,
                               pInfoLog);
            std::cerr
            << ">> INFO: OpenGL Shader - Compile log:"
            << std::endl
            << pInfoLog
            << std::endl;
            
            delete [] pInfoLog;
        } // if
        else
        {
            NSLog(@">> ERROR: Failed allocating memory OpenGL info compile log!");
        } // else
    } // if
} // GLUShaderGetInfoLog

static bool GLUShaderValidate(const GLuint& nShader,
                              const std::string& source)
{
    GLint nIsCompiled = 0;
    
    glGetShaderiv(nShader, GL_COMPILE_STATUS, &nIsCompiled);
    
    if(!nIsCompiled)
    {
        if(!source.empty())
        {
            std::cerr
            << ">> WARNING: OpenGL Shader - Failed to compile shader!"
            << std::endl
            << source
            << std::endl;
        } // if
        
        std::cerr
        << ">> WARNING: OpenGL Shader - Deleted shader object with id = "
        << nShader
        << std::endl;
        
        glDeleteShader(nShader);
    } // if
    
	return nIsCompiled != 0;
} // GLUShaderValidate

static GLuint GLUShaderCreate(const GLenum& target,
                              const GLstring& source)
{
    GLuint nShader = 0;
    
    if(!source.empty())
    {
        nShader = glCreateShader(target);
        
        if(nShader)
        {
            const char *pSource = source.c_str();
            
            glShaderSource(nShader, 1, &pSource, nullptr);
            glCompileShader(nShader);
            
            GLUShaderGetInfoLog(nShader);
        } // if
        
        if(!GLUShaderValidate(nShader, source))
		{
			nShader = 0;
		} // if
    } // if
    
    return nShader;
} // GLUShaderCreate

#pragma mark -
#pragma mark Private - Utilities - Programs

static void GLUProgramGetInfoLog(const GLuint& nProgram)
{
    GLint nInfoLogLength = 0;
    
    glGetProgramiv(nProgram, GL_INFO_LOG_LENGTH, &nInfoLogLength);
    
    if(nInfoLogLength)
    {
        GLchar* pInfoLog = new (std::nothrow) GLchar[nInfoLogLength];
        
        if(pInfoLog != nullptr)
        {
            glGetProgramInfoLog(nProgram,
                                nInfoLogLength,
                                &nInfoLogLength,
                                pInfoLog);
            
            std::cerr
            << ">> INFO: OpenGL Program - Link log:"
            << std::endl
            << pInfoLog
            << std::endl;
            
            delete [] pInfoLog;
        } // if
        else
        {
            NSLog(@">> ERROR: Failed allocating memory OpenGL info link log!");
        } // else
    } // if
} // GLUProgramGetInfoLog

static bool GLUProgramValidate(const GLuint& nProgram)
{
    GLint nIsLinked = 0;
    
    glGetProgramiv(nProgram, GL_LINK_STATUS, &nIsLinked);
    
    if(!nIsLinked)
    {
        std::cerr
        << ">> WARNING: OpenGL Shader - Deleted program object with id = "
        << nProgram
        << std::endl;
        
        glDeleteProgram(nProgram);
    } // if
    
	return nIsLinked != 0;
} // GLUProgramValidate

static GLshaders GLUProgramCreateShaders(const GLuint& nProgram,
                                         const GLsources& sources)
{
    GLuint nShader = 0;
    
    GLshaders shaders;
    
    for(auto& source:sources)
    {
        nShader = GLUShaderCreate(source.first, source.second);
        
        if(nShader)
        {
            glAttachShader(nProgram, nShader);
            
            shaders.push_back(nShader);
        } // if
    } // for
    
    return shaders;
} // GLUProgramCreateShaders

static void GLUProgramDeleteShaders(GLshaders& shaders)
{
    for(auto& shader:shaders)
    {
        if(shader)
        {
            glDeleteShader(shader);
        } // if
    } // for
} // GLUProgramDeleteShaders
        
static bool GLUProgramHasGeometryShader(const GLsources& sources)
{
    GLsources::const_iterator pGeom = sources.find(GL_GEOMETRY_SHADER_EXT);
    
    return pGeom != sources.end();
} // GLUProgramHasGeometryShader
        
static GLuint GLUProgramCreate(const GLsources& sources,
                               const GLenum&   nInType,
                               const GLenum&   nOutType,
                               const GLsizei&  nOutVert)
{
    GLuint nProgram = 0;
    
    if(!sources.empty())
    {
        nProgram = glCreateProgram();
        
        if(nProgram)
        {
            GLshaders shaders = GLUProgramCreateShaders(nProgram, sources);
            
            if(GLUProgramHasGeometryShader(sources))
            {
                glProgramParameteriEXT(nProgram, GL_GEOMETRY_INPUT_TYPE_EXT, nInType);
                glProgramParameteriEXT(nProgram, GL_GEOMETRY_OUTPUT_TYPE_EXT, nOutType);
                glProgramParameteriEXT(nProgram, GL_GEOMETRY_VERTICES_OUT_EXT, nOutVert);
            } // if

            glLinkProgram(nProgram);
            
            GLUProgramDeleteShaders(shaders);
            
            GLUProgramGetInfoLog(nProgram);
            
            if(!GLUProgramValidate(nProgram))
            {
                nProgram = 0;
            } // if
        } // if
    } // if
    
    return nProgram;
} // GLUProgramCreate

#pragma mark -
#pragma mark Public - Interfaces

GLU::Program::Program(CFStringRef pName)
{
    if(pName != nullptr)
    {
        GLtargets targets = {GL_VERTEX_SHADER, GL_FRAGMENT_SHADER};
        mnInType  = 0;
        mnOutType = 0;
        mnOutVert = 0;
        m_Sources = GLUShaderSourcesCreate(targets, pName);
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if
} // Program

GLU::Program::Program(CFStringRef     pName,
                      const GLenum&   nInType,
                      const GLenum&   nOutType,
                      const GLsizei&  nOutVert)
{
    if(pName != nullptr)
    {
        GLtargets targets = {GL_VERTEX_SHADER, GL_FRAGMENT_SHADER, GL_GEOMETRY_SHADER_EXT};
        
        mnInType  = nInType;
        mnOutType = nOutType;
        mnOutVert = nOutVert;
        m_Sources = GLUShaderSourcesCreate(targets, pName);
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if
} // Program

GLU::Program::Program(const GLU::Program& rProgram)
{
    if(!rProgram.m_Sources.empty())
    {
        mnInType  = rProgram.mnInType;
        mnOutType = rProgram.mnOutType;
        mnOutVert = rProgram.mnOutVert;
        m_Sources = rProgram.m_Sources;
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if
} // Copy Constructor

GLU::Program::~Program()
{
    if(mnProgram)
    {
        glDeleteProgram(mnProgram);
        
        mnProgram = 0;
    } // if
    
    if(!m_Sources.empty())
    {
        for(auto& source:m_Sources)
        {
            if(!source.second.empty())
            {
                source.second.clear();
            } // if
        } // for
        
        m_Sources.clear();
    } // if
} // Program

GLU::Program& GLU::Program::operator=(const GLU::Program& rProgram)
{
    if((this != &rProgram) && (!rProgram.m_Sources.empty()))
    {
        if(mnProgram)
        {
            glDeleteProgram(mnProgram);
            
            glUseProgram(0);
            
            mnProgram = 0;
        } // if
        
        mnInType  = rProgram.mnInType;
        mnOutType = rProgram.mnOutType;
        mnOutVert = rProgram.mnOutVert;
        m_Sources = rProgram.m_Sources;
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if

    return *this;
} // Operator =
        
const GLuint& GLU::Program::program() const
{
    return mnProgram;
} // program

void GLU::Program::enable()
{
    glUseProgram(mnProgram);
} // enable

void GLU::Program::disable()
{
    glUseProgram(0);
} // disable

