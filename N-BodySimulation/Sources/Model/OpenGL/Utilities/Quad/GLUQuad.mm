/*
 <codex>
 <import>GLUQuad.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <iostream>

#import <OpenGL/gl.h>

#import "GLMSizes.h"
#import "GLUQuad.h"

#pragma mark -
#pragma mark Private - Data Structures

struct GLU::Quad
{
    volatile int32_t   mnRefCount;  // Reference count
    
    bool  mbResize;                 // Flag to indicate if quad size changed
    bool  mbUpdate;                 // Flag to indicate if the tex coordinates changed
    bool  mbMapped;                 // Flag to indicate if the vbo was mapped
    
	GLuint  mnBID;                  // buffer identifier
	GLuint  mnCount;                // vertex count
	GLuint  mnSize;                 // size of m_Vertices or texture coordinates
	GLuint  mnCapacity;             // vertex size + texture coordinate siez
    
	GLsizei  mnStride;              // vbo stride
    
	GLenum   mnTarget;              // vbo target
	GLenum   mnUsage;               // vbo usage
	GLenum   mnType;                // vbo type
	GLenum   mnMode;                // vbo mode
    
    CGRect  m_Bounds;               // vbo bounds;
    
	GLfloat   mnAspect;             // Aspect ratio
	GLfloat*  mpData;               // vbo data
    GLfloat   m_Vertices[8];        // Quad vertices
    GLfloat   m_TexCoords[8];       // Quad texture coordinates
};

#pragma mark -
#pragma mark Private - Macros

#define BUFFER_OFFSET(i) ((GLchar *)nullptr + (i))

#pragma mark -
#pragma mark Private - Accessors

static bool GLUQuadAcquireBounds(const CGRect& bounds,
                                 GLU::QuadRef pQuad)
{
    bool bSuccess = !CGRectIsEmpty(bounds);
    
    if(bSuccess)
    {
        pQuad->mbResize = !CGRectEqualToRect(bounds, pQuad->m_Bounds);
        
        if(pQuad->mbResize)
        {
            pQuad->m_Bounds.origin.x = bounds.origin.x;
            pQuad->m_Bounds.origin.y = bounds.origin.y;
            
            pQuad->m_Bounds.size.width  = bounds.size.width;
            pQuad->m_Bounds.size.height = bounds.size.height;
            
            pQuad->mnAspect = pQuad->m_Bounds.size.width / pQuad->m_Bounds.size.height;
        } // if
    } // if
    else
    {
        pQuad->m_Bounds.origin.x = 0.0f;
        pQuad->m_Bounds.origin.y = 0.0f;
        
        pQuad->m_Bounds.size.width  = 1920.0f;
        pQuad->m_Bounds.size.height = 1080.0f;
        
        pQuad->mnAspect = pQuad->m_Bounds.size.width / pQuad->m_Bounds.size.height;
    } // else
    
    return bSuccess && pQuad->mbResize;
} // GLUQuadAcquireBounds

static bool GLUQuadSetVertices(const CGRect& bounds,
                               GLU::QuadRef pQuad)
{
    bool bSuccess = GLUQuadAcquireBounds(bounds, pQuad);
    
    if(bSuccess)
    {
        pQuad->m_Vertices[0] = pQuad->m_Bounds.origin.x;
        pQuad->m_Vertices[1] = pQuad->m_Bounds.origin.y;
        
        pQuad->m_Vertices[2] = pQuad->m_Bounds.origin.x + pQuad->m_Bounds.size.width;
        pQuad->m_Vertices[3] = pQuad->m_Bounds.origin.y;
        
        pQuad->m_Vertices[4] = pQuad->m_Bounds.origin.x + pQuad->m_Bounds.size.width;
        pQuad->m_Vertices[5] = pQuad->m_Bounds.origin.y + pQuad->m_Bounds.size.height;
        
        pQuad->m_Vertices[6] = pQuad->m_Bounds.origin.x;
        pQuad->m_Vertices[7] = pQuad->m_Bounds.origin.y + pQuad->m_Bounds.size.height;
    } // if
    
    return bSuccess;
} // GLUQuadSetVertices

static bool GLUQuadSetTextCoords(const bool& bIsInverted,
                                 GLU::QuadRef pQuad)
{
    GLfloat nValue = (bIsInverted) ? 0.0f : 1.0f;
    
    pQuad->mbUpdate = pQuad->m_TexCoords[7] != nValue;
    
    if(pQuad->mbUpdate)
    {
        if(bIsInverted)
        {
            pQuad->m_TexCoords[0]  = 0.0f;
            pQuad->m_TexCoords[1]  = 1.0f;
            
            pQuad->m_TexCoords[2]  = 1.0f;
            pQuad->m_TexCoords[3]  = 1.0f;
            
            pQuad->m_TexCoords[4]  = 1.0f;
            pQuad->m_TexCoords[5]  = 0.0f;
            
            pQuad->m_TexCoords[6]  = 0.0f;
            pQuad->m_TexCoords[7]  = 0.0f;
        } // if
        else
        {
            pQuad->m_TexCoords[0]  = 0.0f;
            pQuad->m_TexCoords[1]  = 0.0f;
            
            pQuad->m_TexCoords[2]  = 1.0f;
            pQuad->m_TexCoords[3]  = 0.0f;
            
            pQuad->m_TexCoords[4]  = 1.0f;
            pQuad->m_TexCoords[5]  = 1.0f;
            
            pQuad->m_TexCoords[6]  = 0.0f;
            pQuad->m_TexCoords[7]  = 1.0f;
        } // else
    } // if
    
    return pQuad->mbUpdate;
} // GLUQuadSetTextCoords

#pragma mark -
#pragma mark Private - Constructor

static void GLUQuadSetUsage(const GLenum& nUsage,
                            GLU::QuadRef pQuad)
{
    switch(nUsage)
    {
        case GL_STREAM_DRAW:
        case GL_STATIC_DRAW:
        case GL_DYNAMIC_DRAW:
            pQuad->mnUsage = nUsage;
            break;
            
        default:
            pQuad->mnUsage = GL_STATIC_DRAW;
            break;
    } // switch
} // GLUQuadSetUsage

static void GLUQuadSetDefaults(GLU::QuadRef pQuad)
{
    std::memset(pQuad, 0x0, sizeof(GLU::Quad));
    
    pQuad->mnRefCount = 1;
	pQuad->mnCount    = 4;
	pQuad->mnSize     = 8 * GLM::Size::kFloat;
	pQuad->mnCapacity = 2 * pQuad->mnSize;
	pQuad->mnType     = GL_FLOAT;
	pQuad->mnMode     = GL_QUADS;
	pQuad->mnTarget   = GL_ARRAY_BUFFER;
    
    pQuad->m_TexCoords[7] = 2.0f;
} // GLUQuadSetDefaults

static GLU::QuadRef GLUQuadCreateWithUsage(const GLenum& nUsage)
{
    GLU::QuadRef pQuad = new (std::nothrow) GLU::Quad;
    
    if(pQuad != nullptr)
    {
        GLUQuadSetDefaults(pQuad);
        GLUQuadSetUsage(nUsage, pQuad);
    } // if
    else
    {
        NSLog(@">> ERROR: OpenGL Quad - Failed allocation quad backing-store!");
        
        return nullptr;
    } // else

	return pQuad;
} // GLUQuadCreateWithUsage

#pragma mark -
#pragma mark Private - Destructors

static void GLUQuadDeleteVertexBuffer(GLU::QuadRef pQuad)
{
    if(pQuad->mnBID)
    {
        glDeleteBuffers(1, &pQuad->mnBID);
    } // if
} // GLUQuadDeleteVertexBuffer

static void GLUQuadDelete(GLU::QuadRef pQuad)
{
	if(pQuad != nullptr)
	{
        GLUQuadDeleteVertexBuffer(pQuad);
		
		delete pQuad;
		
		pQuad = nullptr;
	} // if
} // GLUQuadDelete

#pragma mark -
#pragma mark Private - Utilities - Reference counting

// Increment the refernce count
static GLU::QuadRef GLUQuadRetainCount(GLU::QuadRef pQuad)
{
    GLU::QuadRef pQuadCopy = nullptr;
    
    if(pQuad != nullptr)
    {
        OSAtomicIncrement32Barrier(&pQuad->mnRefCount);
        
        pQuadCopy = pQuad;
    } // if
    
    return pQuadCopy;
} // GLUQuadRetainCount

// Decrement the refernce count
static void GLUQuadReleaseCount(GLU::QuadRef pQuad)
{
    if(pQuad != nullptr)
    {
        OSAtomicDecrement32Barrier(&pQuad->mnRefCount);
        
        if(pQuad->mnRefCount == 0)
        {
            GLUQuadDelete(pQuad);
        } // if
    } // if
} // GLUQuadReleaseCount

#pragma mark -
#pragma mark Private - Utilities - Acquire

static bool GLUQuadAcquireBuffer(GLU::QuadRef pQuad)
{
    if(!pQuad->mnBID)
    {
        glGenBuffers(1, &pQuad->mnBID);
        
        if(pQuad->mnBID)
        {
            glBindBuffer(pQuad->mnTarget, pQuad->mnBID);
            {
                glBufferData(pQuad->mnTarget, pQuad->mnCapacity, nullptr, pQuad->mnUsage);
                
                glBufferSubData(pQuad->mnTarget, 0, pQuad->mnSize, pQuad->m_Vertices);
                glBufferSubData(pQuad->mnTarget, pQuad->mnSize, pQuad->mnSize, pQuad->m_TexCoords);
            }
            glBindBuffer(pQuad->mnTarget, 0);
        } // if
    } // if
    
    return  pQuad->mnBID != 0;
} // GLUQuadAcquireBuffer

#pragma mark -
#pragma mark Private - Utilities - Map/Unmap

static bool GLUQuadMapBuffer(GLU::QuadRef pQuad)
{
    if(pQuad->mbResize && !pQuad->mbMapped)
    {
        glBindBuffer(pQuad->mnTarget,
                     pQuad->mnBID);
        
        glBufferData(pQuad->mnTarget,
                     pQuad->mnCapacity,
                     nullptr,
                     pQuad->mnUsage);
        
        pQuad->mpData = (GLfloat *)glMapBuffer(pQuad->mnTarget, GL_WRITE_ONLY);
        
        pQuad->mbMapped = pQuad->mpData != nullptr;
    } // if
    
    return pQuad->mbMapped;
} // GLUQuadMapBuffer

static bool GLUQuadUnmapBuffer(GLU::QuadRef pQuad)
{
    bool bSuccess = pQuad->mbResize && pQuad->mbMapped;
    
    if(bSuccess)
    {
        bSuccess = glUnmapBuffer(pQuad->mnTarget);
        
        glBindBuffer(pQuad->mnTarget, 0);
        
        pQuad->mbMapped = false;
    } // if
    
    return bSuccess;
} // GLUQuadUnmapBuffer

#pragma mark -
#pragma mark Private - Utilities - Update

static void GLUQuadUpdateBuffer(GLU::QuadRef pQuad)
{
    glBindBuffer(pQuad->mnTarget, pQuad->mnBID);
    
    if(pQuad->mbResize)
    {
        glBufferSubData(pQuad->mnTarget, 0, pQuad->mnSize, pQuad->m_Vertices);
    } // if
    
    if(pQuad->mbUpdate)
    {
        glBufferSubData(pQuad->mnTarget, pQuad->mnSize, pQuad->mnSize, pQuad->m_TexCoords);
    } // if
} // GLUQuadUpdateBuffer

#pragma mark -
#pragma mark Private - Utilities - Draw

static void GLUQuadDrawArrays(GLU::QuadRef pQuad)
{
	glBindBuffer(pQuad->mnTarget, pQuad->mnBID);
    {
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glEnableClientState(GL_VERTEX_ARRAY);
        
        glVertexPointer(2, pQuad->mnType, pQuad->mnStride, BUFFER_OFFSET(0));
        glTexCoordPointer(2, pQuad->mnType, pQuad->mnStride, BUFFER_OFFSET(pQuad->mnSize));
        
        glDrawArrays(pQuad->mnMode, 0, pQuad->mnCount);
        
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
	glBindBuffer(pQuad->mnTarget, 0);
} // GLUQuadDrawArrays

#pragma mark -
#pragma mark Public - Constructor

// Construct a quad with a usage enumerated type
GLU::QuadRef GLU::QuadCreate(const GLenum& nUsage)
{
    return GLUQuadCreateWithUsage(nUsage);
} // GLUQuadCreate

#pragma mark -
#pragma mark Public - Reference Counting

// Retain a quad
GLU::QuadRef GLU::QuadRetain(GLU::QuadRef pQuad)
{
    return GLUQuadRetainCount(pQuad);
} // GLUQuadRetain

// Release a quad
void GLU::QuadRelease(GLU::QuadRef pQuad)
{
    GLUQuadReleaseCount(pQuad);
} // GLUQuadRelease

#pragma mark -
#pragma mark Public - Accessors

// Is the quad finalized?
bool GLU::QuadIsFinalized(GLU::QuadRef pQuad)
{
    return (pQuad != nullptr) ? pQuad->mnBID != 0 : false;
} // GLUQuadIsFinalized

// Set the quad to be inverted
bool GLU::QuadSetIsInverted(const bool& bIsInverted,
                          GLU::QuadRef pQuad)
{
    return (pQuad != nullptr) ? GLUQuadSetTextCoords(bIsInverted, pQuad) : false;
} // GLUQuadSetIsInverted

// Set the quad bounds
bool GLU::QuadSetBounds(const CGRect& bounds,
                      GLU::QuadRef pQuad)
{
    return (pQuad != nullptr) ? GLUQuadSetVertices(bounds, pQuad) : false;
} // GLUQuadSetBounds

#pragma mark -
#pragma mark Public - Updating

// Finalize and acquire a vbo for the quad
bool GLU::QuadFinalize(GLU::QuadRef pQuad)
{
    return (pQuad != nullptr) ? GLUQuadAcquireBuffer(pQuad) : false;
} // GLUQuadFinalize

// Update the quad if either the bounds changed or
// the inverted flag was changed
void GLU::QuadUpdate(GLU::QuadRef pQuad)
{
    if(pQuad != nullptr)
    {
        GLUQuadUpdateBuffer(pQuad);
    } // if
} // GLUQuadUpdate

#pragma mark -
#pragma mark Public - Map/Unmap

// Map to get the base address of the quad's vbo
bool GLU::QuadMap(GLU::QuadRef pQuad)
{
    return (pQuad != nullptr) ? GLUQuadMapBuffer(pQuad) : false;
} // GLUQuadMap

// Unmap to invalidate the base address of the quad's vbo
bool GLU::QuadUnmap(GLU::QuadRef pQuad)
{
    return (pQuad != nullptr) ? GLUQuadUnmapBuffer(pQuad) : false;
} // GLUQuadUnmap

// Get the base address of the quad's vbo
GLfloat* GLU::QuadBuffer(GLU::QuadRef pQuad)
{
    return (pQuad != nullptr) ? pQuad->mpData : nullptr;
} // GLUQuadBuffer

#pragma mark -
#pragma mark Public - Drawing

// Draw the quad
void GLU::QuadDraw(GLU::QuadRef pQuad)
{
    if(pQuad != nullptr)
    {
        GLUQuadDrawArrays(pQuad);
    } // if
} // GLUQuadDraw
