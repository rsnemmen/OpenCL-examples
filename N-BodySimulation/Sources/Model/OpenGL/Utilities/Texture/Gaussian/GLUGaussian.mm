/*
 <codex>
 <import>GLUGaussian.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import <Foundation/Foundation.h>

#import <simd/simd.h>
#import <OpenGL/gl.h>

#import "CFQueue.h"
#import "CMNumerics.h"

#import "GLUGaussian.h"

#pragma mark -
#pragma mark Private - Utilities - Image

static void GLUGaussianInitImage(const GLuint& nTexRes,
                                 dispatch_queue_t& queue_x,
                                 dispatch_queue_t& queue_y,
                                 GLubyte* pImage)
{
    const float nDelta = 2.0f / float(nTexRes);
    
    __block int32_t i = 0;
    __block int32_t j = 0;
    
    __block simd::float2 w = -1.0f;
    
    dispatch_apply(nTexRes, queue_y, ^(size_t y) {
        w.y += nDelta;
        
        dispatch_apply(nTexRes, queue_x, ^(size_t x) {
            w.x += nDelta;
            
            float d = simd::length(w);
            float t = 1.0f;
            
            t = CM::isLT(d, t) ? d : 1.0f;
            
            // Hermite interpolation where u = {1, 0} and v = {0, 0}
            pImage[j] = GLubyte(255.0f * ((2.0f * t - 3.0f) * t * t + 1.0f));
            
            i += 2;
            
            j++;
        });
        
        w.x = -1.0f;
    });
} // GLUGaussianInitImage

static GLubyte* GLUGaussianCreateImage(const GLuint& nTexRes)
{
    GLubyte* pImage = new (std::nothrow) GLubyte[nTexRes * nTexRes];
    
    if(pImage != nullptr)
    {
        CF::Queue queue;
        
        dispatch_queue_t queue_y = queue("com.apple.glu.gaussian.ycoord");
        
        if(queue_y)
        {
            dispatch_queue_t queue_x = queue("com.apple.glu.gaussian.xcoord");
            
            if(queue_x)
            {
                GLUGaussianInitImage(nTexRes, queue_x, queue_y, pImage);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    dispatch_release(queue_x);
                });
            } // if

            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_release(queue_y);
            });
        } // if
    } // if
    else
    {
        NSLog(@">> ERROR: Failed allocating backing-store for a Gaussian image!");
    } // else
    
    return pImage;
} // GLUGaussianCreateImage

#pragma mark -
#pragma mark Private - Utilities - Constructors

static GLuint GLUGaussianCreateTexture(const GLsizei& nTexRes)
{
    GLuint texture = 0;
    
    GLubyte* pImage = GLUGaussianCreateImage(nTexRes);
    
    if(pImage != nullptr)
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            glBindTexture(GL_TEXTURE_2D, texture);
            
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         GL_LUMINANCE8,
                         nTexRes,
                         nTexRes,
                         0,
                         GL_LUMINANCE,
                         GL_UNSIGNED_BYTE,
                         pImage);
        } // if
        
        delete [] pImage;
        
        pImage = nullptr;
    } // if
    
    return texture;
} // GLUGaussianCreateTexture

#pragma mark -
#pragma mark Public - Interfaces

GLU::Gaussian::Gaussian(const GLuint& nTexRes)
{
    mnTarget  = GL_TEXTURE_2D;
    mnTexRes  = nTexRes;
    mnTexture = GLUGaussianCreateTexture(mnTexRes);
} // Constructor

GLU::Gaussian::~Gaussian()
{
    if(mnTexture)
    {
        glDeleteTextures(1, &mnTexture);
        
        mnTexture = 0;
    } // if
} // Destructor

GLU::Gaussian::Gaussian(const GLU::Gaussian::Gaussian& rTexture)
{
    mnTarget  = GL_TEXTURE_2D;
    mnTexRes  = (rTexture.mnTexRes) ? rTexture.mnTexRes : 64;
    mnTexture = GLUGaussianCreateTexture(mnTexRes);
} // Copy Constructor

GLU::Gaussian& GLU::Gaussian::operator=(const GLU::Gaussian& rTexture)
{
    if(this != &rTexture)
    {
        if(mnTexture)
        {
            glDeleteTextures(1, &mnTexture);
            
            mnTexture = 0;
        } // if
        
        mnTarget  = GL_TEXTURE_2D;
        mnTexRes  = (rTexture.mnTexRes) ? rTexture.mnTexRes : 64;
        mnTexture = GLUGaussianCreateTexture(mnTexRes);
    } // if
    
    return *this;
} // Operator =

void GLU::Gaussian::enable()
{
    glBindTexture(mnTarget, mnTexture);
} // enable

void GLU::Gaussian::disable()
{
    glBindTexture(mnTarget, 0);
} // disable

const GLuint& GLU::Gaussian::texture() const
{
    return mnTexture;
} // texture

const GLenum& GLU::Gaussian::target()  const
{
    return mnTarget;
} // target
