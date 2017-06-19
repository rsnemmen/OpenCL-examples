/*
 <codex>
 <import>HUDButton.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Utilities

#import <cstdlib>
#import <cmath>

#import <unordered_map>

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

#import "CFText.h"

#import "GLMTransforms.h"

#import "GLUText.h"
#import "GLUTexture.h"

#import "HUDButton.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace HUD::Button;

#pragma mark -
#pragma mark Private - Enumerated Types

enum HUDTextureTypes
{
    eHUDMeterBackground = 0,
    eHUDMeterNeedle,
    eHUDMeterLegend,
    eHUDMeterMax
};

#pragma mark -
#pragma mark Private - Constants

static const CGBitmapInfo kHUDBitmapInfo = kCGImageAlphaPremultipliedLast;

static const GLuint kHUDBitsPerComponent = 8;
static const GLuint kHUDSamplesPerPixel  = 4;

static const GLdouble kHUDCenterX = 0.5f;
static const GLdouble kHUDCenterY = 0.5f;

#pragma mark -
#pragma mark Private - Containers

static std::unordered_map<std::string, GLuint> HUDCreateTextureWithLabels;

#pragma mark -
#pragma mark Private - Utilities

static void HUDAddRoundedRectToPath(CGContextRef context,
                                    const CGRect& rect,
                                    const GLdouble& ovalWidth,
                                    const GLdouble& ovalHeight)
{
    if((ovalWidth == 0.0f) || (ovalHeight == 0.0f))
    {
        CGContextAddRect(context, rect);
        
        return;
    } // if
    
    CGContextSaveGState(context);
    {
        CGContextTranslateCTM(context,
                              CGRectGetMinX(rect),
                              CGRectGetMinY(rect));
        
        CGContextScaleCTM(context, ovalWidth, ovalHeight);
        
        GLdouble width  = CGRectGetWidth(rect)  / ovalWidth;
        GLdouble height = CGRectGetHeight(rect) / ovalHeight;
        
        GLdouble hWidth  = 0.5f * width;
        GLdouble hHeight = 0.5f * height;
        
        CGContextMoveToPoint(context, width, hHeight);
        {
            CGContextAddArcToPoint(context, width, height, hWidth,  height, 1.0f);
            CGContextAddArcToPoint(context,  0.0f, height,   0.0f, hHeight, 1.0f);
            CGContextAddArcToPoint(context,  0.0f,   0.0f, hWidth,    0.0f, 1.0f);
            CGContextAddArcToPoint(context, width,   0.0f,  width, hHeight, 1.0f);
        }
        CGContextClosePath(context);
    }
    CGContextRestoreGState(context);
} // HUDAddRoundedRectToPath

static GLuint HUDButtonCreateTexture(const CGSize& rSize)
{
    GLuint texture = 0;
    
    glGenTextures(1, &texture);
    
    if(texture)
    {
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
        {
            CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            if(pColorspace != nullptr)
            {
                const GLsizei width  = GLsizei(rSize.width);
                const GLsizei height = GLsizei(rSize.height);
                
                const size_t bpp = width * kHUDSamplesPerPixel;
                
                CGContextRef pContext = CGBitmapContextCreate(nullptr,
                                                              width,
                                                              height,
                                                              kHUDBitsPerComponent,
                                                              bpp,
                                                              pColorspace,
                                                              kHUDBitmapInfo);
                
                if(pContext != nullptr)
                {
                    GLdouble cx = kHUDCenterX * rSize.width;
                    GLdouble cy = kHUDCenterY * rSize.height;
                    GLdouble sx = 0.05f * rSize.width;
                    GLdouble sy = 0.5f  * rSize.height - 32.0f;
                    
                    CGRect bound = CGRectMake(sx, sy, 0.9f * rSize.width, 64.0f);
                    
                    // background
                    CGContextTranslateCTM(pContext, 0.0f, height);
                    CGContextScaleCTM(pContext, 1.0f, -1.0f);
                    CGContextClearRect(pContext, CGRectMake(0, 0.0f, width, height));
                    CGContextSetRGBFillColor(pContext, 0.0f, 0.0f, 0.0f, 0.8f);
                    
                    HUDAddRoundedRectToPath(pContext, bound, 32.0f, 32.0f);
                    
                    CGContextFillPath(pContext);
                    
                    // top bevel
                    CGContextSaveGState(pContext);
                    {
                        size_t count = 2;
                        
                        GLdouble locations[2] = { 0.0f, 1.0f };
                        
                        GLdouble components[8] =
                        {
                            1.0f, 1.0f, 1.0f, 0.5f,  // Start color
                            0.0f, 0.0f, 0.0f, 0.0f
                        }; // End color
                        
                        HUDAddRoundedRectToPath(pContext, bound, 32.0f, 32.0f);
                        
                        CGContextEOClip(pContext);
                        
                        CGGradientRef pGradient = CGGradientCreateWithColorComponents(pColorspace,
                                                                                      components,
                                                                                      locations,
                                                                                      count);
                        
                        
                        if(pGradient != nullptr)
                        {
                            CGContextDrawLinearGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, cy + 32.0f),
                                                        CGPointMake(cx, cy),
                                                        0.0f);
                            
                            CGContextDrawLinearGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, cy - 32.0f),
                                                        CGPointMake(cx, cy - 16.0f),
                                                        0.0f);
                            
                            CFRelease(pGradient);
                        } // if
                    }
                    CGContextRestoreGState(pContext);
                    
                    const void* pData = CGBitmapContextGetData(pContext);
                    
                    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
                                 0,
                                 GL_RGBA,
                                 width,
                                 height,
                                 0,
                                 GL_RGBA,
                                 GL_UNSIGNED_BYTE,
                                 pData);
                    
                    CFRelease(pContext);
                } // if
                
                CFRelease(pColorspace);
            } // if
        }
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
    } // if
    
    return texture;
} // HUDButtonCreateTexture

#pragma mark -
#pragma mark Public - Button - Utilities

Image::Image(const Bounds& frame,
             const CGFloat& size)
{
    if(!CGRectIsEmpty(frame))
    {
        mbIsItalic   = false;
        mnSize       = (size > 12.0f) ? size : 24.0f;
        m_Label      = "";
        mnWidth      = GLsizei(frame.size.width  + 0.5f);
        mnHeight     = GLsizei(frame.size.height + 0.5f);
        m_Texture[0] = HUDButtonCreateTexture(frame.size);
        m_Texture[1] = 0;
        mpText       = nullptr;
        mpQuad       = GLU::QuadCreate(GL_DYNAMIC_DRAW);
    } // if
} // Constructor

Image::Image(const Bounds& frame,
             const CGFloat& size,
             const bool& italic,
             const Label& label)
{
    if(!CGRectIsEmpty(frame))
    {
        mnWidth      = GLsizei(frame.size.width  + 0.5f);
        mnHeight     = GLsizei(frame.size.height + 0.5f);
        mbIsItalic   = italic;
        mnSize       = (size > 12.0f) ? size : 24.0f;
        m_Label      = label;
        mpQuad       = GLU::QuadCreate(GL_DYNAMIC_DRAW);
        m_Texture[0] = HUDButtonCreateTexture(frame.size);
        
        mpText = new (std::nothrow) GLU::Text(m_Label, mnSize, mbIsItalic, mnWidth, mnHeight);
        
        if(mpText != nullptr)
        {
            m_Texture[1] = mpText->texture();
        } // if
    } // if
} // Constructor

Image::~Image()
{
    if(m_Texture[0])
    {
        glDeleteTextures(1, &m_Texture[0]);
        
        m_Texture[0] = 0;
    } // if
    
    if(mpText != nullptr)
    {
        delete mpText;
        
        mpText = nullptr;
    } // if
    
    GLU::QuadRelease(mpQuad);
    
    mpQuad = nullptr;
} // Destructor

bool Image::setLabel(const Label& label)
{
    if(mpText != nullptr)
    {
        GLU::Text* pText = new (std::nothrow) GLU::Text(m_Label, mnSize, mbIsItalic, mnWidth, mnHeight);
        
        if(pText != nullptr)
        {
            delete mpText;
            
            m_Label      = label;
            mpText       = pText;
            m_Texture[1] = mpText->texture();
        } // if
    } // if
    
    return m_Texture[1] != 0;
} // NBodySetSimulatorDescription

void Image::draw(const bool& selected,
                 const Position& position,
                 const Bounds& bounds)
{
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    {
        glMatrixMode(GL_MODELVIEW);

        GLM::load(true, GLM::translate(position.x, position.y, 0.0f));
        
        glColor3f(1.0f, 1.0f, 1.0f);
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB);
        {
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, m_Texture[0]);
            {
                glMatrixMode(GL_TEXTURE);
                
                simd::float4x4 tm = GLM::texture(true);
                
                GLM::load(true, GLM::scale(bounds.size.width, bounds.size.height, 1.0f));
                
                if(selected)
                {
                    glColor3f(0.5f, 0.5f, 0.5f);
                } // if
                else
                {
                    glColor3f(0.3f, 0.3f, 0.3f);
                } // else
                
                GLU::QuadSetIsInverted(false, mpQuad);
                GLU::QuadSetBounds(bounds, mpQuad);
                
                if(!GLU::QuadIsFinalized(mpQuad))
                {
                    GLU::QuadFinalize(mpQuad);
                } // if
                else
                {
                    GLU::QuadUpdate(mpQuad);
                } // else
                
                GLU::QuadDraw(mpQuad);
                
                GLM::load(true, tm);
            }
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
        }
        glDisable(GL_TEXTURE_RECTANGLE_ARB);
        
        glEnable(GL_TEXTURE_2D);
        {
            glBindTexture(GL_TEXTURE_2D, m_Texture[1]);
            {
                if(selected)
                {
                    glColor3f(0.4f, 0.7f, 1.0f);
                } // if
                else
                {
                    glColor3f(0.85f, 0.2f, 0.2f);
                } // else
                
                glMatrixMode(GL_MODELVIEW);

                GLM::load(true, GLM::translate(0.0f, -10.0f, 0.0f));
                
                GLU::QuadSetIsInverted(true, mpQuad);
                GLU::QuadSetBounds(bounds, mpQuad);
                
                GLU::QuadUpdate(mpQuad);
                GLU::QuadDraw(mpQuad);
                
                GLM::load(true, GLM::translate(0.0f, 10.0f, 0.0f));
                
                glColor3f(1.0f, 1.0f, 1.0f);
            }
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        glDisable(GL_TEXTURE_2D);
    }
    glDisable(GL_BLEND);
} // Draw
