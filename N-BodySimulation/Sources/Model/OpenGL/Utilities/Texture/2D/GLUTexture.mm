/*
 <codex>
 <import>GLUTexture.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <memory>
#import <cmath>

#import <OpenGL/gl.h>

#import "GLUTexture.h"

#pragma mark -
#pragma mark Private - Utilities - Constructors

static GLuint GLUTextureCreate(const GLenum& target,
                               const GLsizei& width,
                               const GLsizei& height,
                               const bool&  mipmap,
                               const void * const pData)
{
    GLuint texture = 0;
    
    glEnable(target);
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            glBindTexture(target, texture);
            
            if(mipmap)
            {
                glTexParameteri(target, GL_GENERATE_MIPMAP, GL_TRUE);
                glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            } // if
            else
            {
                glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            } // else
            
            glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glTexImage2D(target,
                         0,
                         GL_RGBA,
                         GLsizei(width),
                         GLsizei(height),
                         0,
                         GL_RGBA,
                         GL_UNSIGNED_BYTE,
                         pData);
        } // if
    }
    glDisable(target);
    
    return texture;
} // GLUTextureCreate

static void GLUTextureUpdate(const GLuint& texture,
                             const GLenum& target,
                             const GLsizei& width,
                             const GLsizei& height,
                             const void * const pData)
{
    glBindTexture(target, texture);
    
    glTexSubImage2D(target, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pData);
} // GLUTextureUpdate

#pragma mark -
#pragma mark Public - Interfaces

GLU::Texture::Texture(CFStringRef   pName,
                      CFStringRef   pExt,
                      const GLenum& nTarget,
                      const bool&   bMipmap)
{
    mpBitmap = new (std::nothrow) CG::Bitmap(pName, pExt);
    
    if(mpBitmap != nullptr)
    {
        const void* pData = mpBitmap->data();
        
        mbMipmaps = bMipmap;
        mnTarget  = nTarget;
        mnWidth   = GLsizei(mpBitmap->width());
        mnHeight  = GLsizei(mpBitmap->height());
        mnTexture = GLUTextureCreate(mnTarget, mnWidth, mnHeight, mbMipmaps, pData);
    } // if
    else
    {
        NSLog(@">> ERROR: Failed allocating memory for the bitmap context!");
    } // else
} // Constructor

GLU::Texture::~Texture()
{
    if(mnTexture)
    {
        glDeleteTextures(1, &mnTexture);
        
        mnTexture = 0;
    } // if
    
    if(mpBitmap != nullptr)
    {
        delete mpBitmap;
        
        mpBitmap = nullptr;
    } // if
} // Destructor

GLU::Texture::Texture(const GLU::Texture::Texture& rTexture)
{
    mnTarget  = rTexture.mnTarget;
    mbMipmaps = rTexture.mbMipmaps;
    mnWidth   = rTexture.mnWidth;
    mnHeight  = rTexture.mnHeight;
    mpBitmap  = new (std::nothrow) CG::Bitmap(rTexture.mpBitmap);
    
    if(mpBitmap != nullptr)
    {
        const void* pData = mpBitmap->data();
        
        mnTexture = GLUTextureCreate(mnTarget, mnWidth, mnHeight, mbMipmaps, pData);
    } // if
} // Copy Constructor

GLU::Texture& GLU::Texture::operator=(const GLU::Texture& rTexture)
{
    if(this != &rTexture)
    {
        const void* pData = nullptr;
        
        if(rTexture.mpBitmap != nullptr)
        {
            bool bSuccess = (rTexture.mnWidth == mnWidth) && (rTexture.mnHeight == mnHeight);
            
            if(bSuccess)
            {
                const CGContextRef pContext = rTexture.mpBitmap->context();
                
                bSuccess = mpBitmap->copy(pContext);
            } // if
            
            if(!bSuccess)
            {
                CG::Bitmap* pBitmap = new (std::nothrow) CG::Bitmap(rTexture.mpBitmap);
                
                if(pBitmap != nullptr)
                {
                    if(mpBitmap != nullptr)
                    {
                        delete mpBitmap;
                        
                        mpBitmap = nullptr;
                    } // if
                    
                    mpBitmap = pBitmap;
                } // if
                else
                {
                    NSLog(@">> ERROR: Failed allocating memory for a copy of bitmap context!");
                    
                    return *this;
                } // else
            } // else
            
            pData = mpBitmap->data();
        } // if
        
        bool bTarget = mnTarget  == rTexture.mnTarget;
        bool bMipmap = mbMipmaps == rTexture.mbMipmaps;
        
        if(bTarget && bMipmap)
        {
            GLUTextureUpdate(mnTexture, mnTarget, mnWidth, mnHeight, pData);
        } // if
        else
        {
            glDeleteTextures(1, &mnTexture);
            
            mnTarget  = rTexture.mnTarget;
            mbMipmaps = rTexture.mbMipmaps;
            mnWidth   = rTexture.mnWidth;
            mnHeight  = rTexture.mnHeight;
            mnTexture = GLUTextureCreate(mnTarget, mnWidth, mnHeight, mbMipmaps, pData);
        } // else
    } // if
    
    return *this;
} // Operator =

void GLU::Texture::enable()
{
    glBindTexture(mnTarget, mnTexture);
} // enable

void GLU::Texture::disable()
{
    glBindTexture(mnTarget, 0);
} // disable

const GLuint& GLU::Texture::texture() const
{
    return mnTexture;
} // texture

const GLenum& GLU::Texture::target()  const
{
    return mnTarget;
} // target
