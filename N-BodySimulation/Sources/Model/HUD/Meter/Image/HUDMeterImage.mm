/*
 <codex>
 <import>HUDMeterImage.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Utilities

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

#import "CTFrame.h"

#import "GLMConstants.h"
#import "GLMTransforms.h"

#import "GLUText.h"
#import "GLUTexture.h"

#import "HUDMeterImage.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace HUD::Meter;

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

static const GLdouble kHUDTicks_f    = 8.0f;
static const GLdouble kHUDSubTicks_f = 4.0f;

static const GLint kHUDTicks           = 8;
static const GLint kHUDSubTicks        = 4;
static const GLint kHUDNeedleThickness = 12;
static const GLint kHUDOffscreen       = 5000;

static const GLuint kHUDBitsPerComponent = 8;
static const GLuint kHUDSamplesPerPixel  = 4;

static const GLdouble kHUDLegendWidth  = 256.0f;
static const GLdouble kHUDLegendHeight = 64.0f;
static const GLdouble kHUDValueWidth   = 128.0f;
static const GLdouble kHUDValueHeight  = 64.0f;

static const simd::double2 kHUDCenter = {0.5f, 0.5f};

#pragma mark -
#pragma mark Private - Utilities

static String HUDInteger2String(const GLuint& i)
{
    char buffer[16];
    
    sprintf(buffer, "%u", i);
    
    return String(buffer);
} // HUDInteger2String

static GLuint HUDEmplaceTextureWithLabel(const GLuint& nKey,
                                         Hash& rHash)
{
    GLuint nTexture = 0;
    
    GLU::Text* pValue = nullptr;
    
    String key = HUDInteger2String(nKey);
    
    Hash::const_iterator  pIter = rHash.find(key);
    
    if(pIter == rHash.end())
    {
        pValue = new  (std::nothrow) GLU::Text(key, 52.0f, true, kHUDValueWidth, kHUDValueHeight);
        
        if(pValue != nullptr)
        {
            rHash.emplace(key, pValue);
        } // if
        else
        {
            NSLog(@">> ERROR: Failed acquiring an OpenGL text label!");
        } // else
    } // if
    else
    {
        pValue = pIter->second;
    } // else
    
    if(pValue != nullptr)
    {
        nTexture = pValue->texture();
    } // if
    
    return nTexture;
} // HUDEmplaceTextureWithLabel

static void HUDDrawMark(CGContextRef pContext,
                        const CGPoint& rOrigin,
                        const std::string& rText,
                        const std::string& rFont,
                        const GLfloat& nFontSize,
                        const CTTextAlignment& nTextAlign)
{
    CT::Frame* pFrame = new CT::Frame(rText, rFont, nFontSize, rOrigin, nTextAlign);
    
    if(pFrame != nullptr)
    {
        pFrame->draw(pContext);
        
        delete pFrame;
    } // if
    else
    {
        NSLog(@">> ERROR: Failed acquiring a CoreText label!");
    } // else
} // HUDDrawMark

static void HUDDrawMarks(CGContextRef pContext,
                         const CGPoint& center,
                         const size_t& iMax,
                         const CGFloat& needle,
                         const CGFloat& fontSize,
                         const std::string& font,
                         const CTTextAlignment& textAlign)
{
    GLdouble radial = 0.82f * needle;
    GLdouble angle  = 0.0f;
    
    CGPoint origin;
    
    GLdouble cos = 0.0f;
    GLdouble sin = 0.0f;
    
    simd::double2 vCoord  = 0.0f;
    simd::double2 vDelta  = 0.0f;
    simd::double2 vCenter = 0.0f;
    simd::double2 vOrigin = 0.0f;
    
    GLchar text[5]= {0x0, 0x0, 0x0, 0x0, '\0'};
    
    size_t i;
    
    const size_t iDelta = iMax / kHUDTicks;
    
    for(i = 0 ; i <= iMax ; i += iDelta)
    {
        sprintf(text, "%ld", i);
        
        // hardcoded text centering for this font size
        if(i > 999)
        {
            vDelta.x = -24.0f;
        } // if
        else if(i > 99)
        {
            vDelta.x = -18.0f;
        } // else if
        else if(i > 0)
        {
            vDelta.x = -14.0f;
        } // else if
        else
        {
            vDelta.x = -12.0f;
        } // else
        
        vDelta.y = -6.0f;
        
        angle = GLM::k4PiDiv3_f * i / iMax - GLM::kPiDiv6_f;
        
        __sincos(angle, &sin, &cos);
        
        vCoord  = {-cos, sin};
        vCenter = {center.x, center.y};
        
        vOrigin = vCenter + vDelta + radial * vCoord;
        
        origin = CGPointMake(vOrigin.x, vOrigin.y);
        
        HUDDrawMark(pContext, origin, text, font, fontSize, textAlign);
        
        text[0]= 0x0;
        text[1]= 0x0;
        text[2]= 0x0;
        text[3]= 0x0;
    } // for
} // HUDDrawMarks

static void HUDDrawMarks(CGContextRef pContext,
                         const GLsizei& width,
                         const GLsizei& height,
                         const size_t& max)
{
    GLint i, start, end, section;

    GLdouble angle, cos, sin, tick;
    
    GLdouble redline = kHUDTicks_f * kHUDSubTicks_f * 0.8f;
    GLdouble radius  = 0.5f * (width > height ? width : height);
    GLdouble needle  = radius * 0.85f;
    
    simd::double2 c = {GLfloat(width), GLfloat(height)};
    
    c *= kHUDCenter;
    
    simd::double2 u = 0.0f;
    simd::double2 v = 0.0f;
    
    simd::double4 q = {c.x, c.x, c.y, c.y};
    simd::double4 r = 0.0f;
    
    for(section = 0; section < 2; ++section)
    {
        start = section ? redline + 1 : 0;
        end   = section ? kHUDTicks * kHUDSubTicks : redline;
        
        if (section)
        {
            CGContextSetRGBStrokeColor(pContext, 1.0f, 0.1f, 0.1f, 1.0f);
        } // if
        else
        {
            CGContextSetRGBStrokeColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
        } // else
        
        // inner tick ring
        r.x = 0.97f * needle;
        r.y = 1.04f * needle;
        r.z = 1.00f * needle;
        r.w = 1.01f * needle;
        
        for(i = start; i <= end ; ++i)
        {
            tick  = i / (kHUDSubTicks_f * kHUDTicks_f);
            angle = GLM::k4PiDiv3_f * tick - GLM::kPiDiv6_f;
            
            __sincos(angle, &sin, &cos);
            
            if(i % kHUDSubTicks != 0)
            {
                u = q.xy - cos * r.xy;
                v = q.zw + sin * r.xy;
                
                CGContextMoveToPoint(pContext, u.x, v.x);
                CGContextAddLineToPoint(pContext, u.y, v.y);
            }
            else
            {
                u = q.xy - cos * r.zw;
                v = q.zw + sin * r.zw;
                
                CGContextMoveToPoint(pContext, u.x, v.x);
                CGContextAddLineToPoint(pContext, u.y, v.y);
            }
        } // for
        
        CGContextSetLineWidth(pContext, 2.0f);
        CGContextStrokePath(pContext);
        
        // outer tick ring
        start = (start / kHUDSubTicks) + section;
        end   = end / kHUDSubTicks;
        
        r.x = 1.05f * needle;
        r.y = 1.14f * needle;
        
        for(i = start; i <= end ; ++i)
        {
            tick  = i / kHUDTicks_f;
            angle = GLM::k4PiDiv3_f * tick - GLM::kPiDiv6_f;
            
            __sincos(angle, &sin, &cos);
            
            u = q.xy - cos * r.xy;
            v = q.zw + sin * r.xy;
            
            CGContextMoveToPoint(pContext, u.x, v.x);
            CGContextAddLineToPoint(pContext, u.y, v.y);
        } // for
        
        CGContextSetLineWidth(pContext, 3.0f);
        CGContextStrokePath(pContext);
    } // for
    
    CGPoint center = CGPointMake(c.x, c.y);

    HUDDrawMarks(pContext,
                 center,
                 max,
                 needle,
                 18.0f,
                 "Helvetica-Bold",
                 kCTTextAlignmentCenter);
} // HUDDrawMarks

static void HUDAcquireShadowWithColor(CGContextRef pContext,
                                      CGSize& offset,
                                      const CGFloat& blur,
                                      const CGFloat* pColors)
{
    CGColorRef pShadowColor = CGColorCreateGenericRGB(pColors[0],
                                                      pColors[1],
                                                      pColors[2],
                                                      pColors[3]);
    
    if(pShadowColor != nullptr)
    {
        CGContextSetShadowWithColor(pContext,
                                    offset,
                                    blur,
                                    pShadowColor);
        
        CFRelease(pShadowColor);
    } // if
} // HUDAcquireShadowWithColor

static void HUDShadowAcquireWithColor(CGContextRef pContext)
{
    CGSize  offset    = CGSizeMake(0.0f, kHUDOffscreen);
    CGFloat colors[4] = {0.5f, 0.5f, 1.0f, 0.7f};
    
    HUDAcquireShadowWithColor(pContext, offset, 48.0f, colors);
} // HUDShadowAcquireWithColor

static void HUDBackgroundShadowAcquireWithColor(CGContextRef pContext)
{
    CGSize  offset    = CGSizeMake(0.0f, 1.0f);
    CGFloat colors[4] = {0.7f, 0.7f, 1.0f, 0.9f};
    
    HUDAcquireShadowWithColor(pContext, offset, 6.0f, colors);
} // HUDBackgroundShadowAcquireWithColor

static void HUDNeedleShadowAcquireWithColor(CGContextRef pContext)
{
    CGSize  offset    = CGSizeMake(0.0f, 1.0f);
    CGFloat colors[4] = {0.0f, 0.0f, 0.5f, 0.7f};
    
    HUDAcquireShadowWithColor(pContext, offset, 6.0f, colors);
} // HUDNeedleShadowAcquireWithColor

static GLuint HUDBackgroundCreateTexture(const GLsizei& width,
                                         const GLsizei& height,
                                         const size_t& max)
{
    GLuint texture = 0;
    
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            if(pColorspace != nullptr)
            {
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
                    simd::double2 c = {GLdouble(width), GLdouble(height)};
                    
                    c *= kHUDCenter;
                    
                    GLdouble radius = 0.5f * (width > height ? width : height);
                    GLdouble needle = radius * 0.85f;
                    
                    // background
                    CGContextTranslateCTM(pContext, 0.0f, height);
                    CGContextScaleCTM(pContext, 1.0f, -1.0f);
                    CGContextClearRect(pContext, CGRectMake(0, 0, width, height));
                    CGContextSetRGBFillColor(pContext, 0.0f, 0.0f, 0.0f, 0.7f);
                    CGContextAddArc(pContext, c.x, c.y, radius, 0.0f, GLM::kTwoPi_f, false);
                    CGContextFillPath(pContext);
                    
                    size_t count = 2;
                    
                    GLdouble locations[2]  = { 0.0f, 1.0f };
                    GLdouble components[8] =
                    {
                        1.0f, 1.0f, 1.0f, 0.5f,  // Start color
                        0.0f, 0.0f, 0.0f, 0.0f
                    }; // End color
                    
                    CGGradientRef pGradient = CGGradientCreateWithColorComponents(pColorspace,
                                                                                  components,
                                                                                  locations,
                                                                                  count);
                    if(pGradient != nullptr)
                    {
                        CGPoint center = CGPointMake(c.x, c.y);
                    
                        CGContextSaveGState(pContext);
                        {
                            CGContextAddArc(pContext, c.x, c.y, radius, 0.0f, GLM::kTwoPi_f, false);
                            CGContextAddArc(pContext, c.x, c.y, needle * 1.05, 0.0f, GLM::kTwoPi_f, false);
                            CGContextEOClip(pContext);
                            
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        center,
                                                        radius * 1.01f,
                                                        CGPointMake(c.x, c.y * 0.96f),
                                                        radius * 0.98f,
                                                        0);
                            // bottom rim light
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        center,
                                                        radius * 1.01f,
                                                        CGPointMake(c.x, c.y * 1.04f),
                                                        radius * 0.98f,
                                                        0);
                            // top bevel
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(c.x, c.y * 2.2f),
                                                        radius*0.2,
                                                        center,
                                                        radius,
                                                        0);
                        }
                        CGContextRestoreGState(pContext);
                        
                        // bottom bevel
                        CGContextSaveGState(pContext);
                        {
                            CGContextAddArc(pContext, c.x, c.y, needle * 1.05f, 0.0f, GLM::kTwoPi_f, false);
                            CGContextAddArc(pContext, c.x, c.y, needle * 0.96f, 0.0f, GLM::kTwoPi_f, false);
                            CGContextEOClip(pContext);
                            
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(c.x, -0.5f * c.y),
                                                        radius * 0.2f,
                                                        center,
                                                        radius,
                                                        0);
                        }
                        CGContextRestoreGState(pContext);
                        
                        CFRelease(pGradient);
                    } // if
                    
                    // top rim light
                    
                    CGContextSetRGBFillColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
                    CGContextSetRGBStrokeColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
                    CGContextSetLineCap(pContext, kCGLineCapRound);
                    
                    // draw several glow passes, with the content offscreen
                    CGContextTranslateCTM(pContext, 0.0f, kHUDOffscreen - 10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, 0.0f, 20.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, 20.0f, 0.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -kHUDOffscreen);
                    
                    // draw real content
                    HUDBackgroundShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
                    
                    const void *pData  = CGBitmapContextGetData(pContext);
                    
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
        } // if
    }
    glDisable(GL_TEXTURE_RECTANGLE_ARB);
    
    return texture;
} // HUDBackgroundCreateTexture

static GLdouble HUDAngleForValue(GLdouble& val,
                                 const size_t& max)
{
    if(val < 0.0f)
    {
        val = 0.0f;
    } // if
    
    GLdouble max_f = GLdouble(max);
    
    if(val > (max_f * 1.05f))
    {
        val = max_f + 1.05f;
    } // if
    
    return  GLM::kPiDiv6_f - GLM::k4PiDiv3_f * val / max_f;
} // HUDAngleForValue

static void HUDNeedleDraw(CGContextRef pContext,
                          const GLsizei& width,
                          const GLsizei& height,
                          const GLfloat& angle)
{
    simd::double2 c = {GLfloat(width), GLfloat(height)};
    
    c *= kHUDCenter;
    
    GLdouble cos = 0.0f;
    GLdouble sin = 0.0f;
    
    __sincos(angle, &sin, &cos);
    
    simd::double2 d  = {cos, sin};
    simd::double2 hd = -0.5f * d;
    
    GLfloat radius = 0.5f * (width > height ? width : height);
    GLfloat needle = radius * 0.85f;
    
    simd::double2 p = c - needle * d;
    
    CGContextMoveToPoint(pContext, p.x - hd.y, p.y + hd.x);
    CGContextAddLineToPoint(pContext, p.x + hd.y, p.y - hd.x);
    
    d  *= kHUDNeedleThickness;
    hd *= kHUDNeedleThickness;
    
    p = c + d;
    
    CGContextAddLineToPoint(pContext, p.x - hd.y, p.y + hd.x);
    
    CGContextAddArc(pContext,
                    p.x,
                    p.y,
                    0.5f * kHUDNeedleThickness,
                    angle - GLM::kHalfPi_f,
                    angle + GLM::kHalfPi_f,
                    false);
    
    CGContextAddLineToPoint(pContext, p.x + hd.y, p.y - hd.x);
    
    CGContextFillPath(pContext);
} // HUDNeedleDraw

static GLuint HUDNeedleCreateTexture(const GLsizei& width,
                                     const GLsizei& height)
{
    GLuint texture = 0;
    
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            if(pColorspace != nullptr)
            {
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
                    GLdouble angle = 0.0f;
                    
                    simd::double2 c = {GLdouble(width), GLdouble(height)};
                    
                    c *= kHUDCenter;
                    
                    CGContextTranslateCTM(pContext, 0.0f, height);
                    CGContextScaleCTM(pContext, 1.0, -1.0);
                    CGContextClearRect(pContext, CGRectMake(0.0f, 0.0f, width, height));
                    
                    CGContextSaveGState(pContext);
                    {
                        GLdouble radius = 0.5f * (width > height ? width : height);
                        GLdouble needle = radius * 0.85f;
                        
                        size_t count = 2;
                        
                        GLdouble locations[2] = { 0.0f, 1.0f };
                        
                        GLdouble components[8] =
                        {
                            0.7f, 0.7f, 1.0f, 0.7f,  // Start color
                            0.0f, 0.0f, 0.0f, 0.0f
                        }; // End color
                        
                        CGContextAddArc(pContext, c.x, c.y, needle * 1.05, 0.0f, GLM::kTwoPi_f, false);
                        CGContextAddArc(pContext, c.x, c.y, needle * 0.96, 0.0f, GLM::kTwoPi_f, false);
                        
                        CGContextEOClip(pContext);
                        
                        CGGradientRef pGradient = CGGradientCreateWithColorComponents(pColorspace,
                                                                                      components,
                                                                                      locations,
                                                                                      count);
                        if(pGradient != nullptr)
                        {
                            // draw glow reflecting on inner bevel
                            GLdouble cos = 0.0f;
                            GLdouble sin = 0.0f;
                            
                            __sincos(angle, &sin, &cos);
                            
                            simd::double2 d = {cos, sin};
                            
                            d = c * (1.0f - d);
                            
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(d.x, d.y),
                                                        0.1f * radius,
                                                        CGPointMake(c.x, c.y),
                                                        radius,
                                                        0.0f);
                            
                            CFRelease(pGradient);
                        } // if
                    }
                    CGContextRestoreGState(pContext);
                    
                    CGContextSetRGBFillColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
                    
                    // draw several glow passes, with the content offscreen
                    CGContextTranslateCTM(pContext, 0.0f, kHUDOffscreen - 10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, 0.0f, 20.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, 20.0f, 0.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -kHUDOffscreen);
                    
                    // draw real content
                    HUDNeedleShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
                    
                    const void* pData  = CGBitmapContextGetData(pContext);
                    
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
        } // if
    }
    glDisable(GL_TEXTURE_RECTANGLE_ARB);
    
    return texture;
} // HUDNeedleCreateTexture

#pragma mark -
#pragma mark Public - Meter - Image

Image::Image(const GLsizei& width,
             const GLsizei& height,
             const size_t& max,
             const String& legend)
{
    mnWidth  = width;
    mnHeight = height;
    mnMax    = max;
    mnLimit  = GLdouble(mnMax);
    m_Legend = legend;
    
    mnValue  = 0.0f;
    mnSmooth = 0.0f;
    
    GLdouble fWidth  = CGFloat(mnWidth);
    GLdouble fHeight = CGFloat(mnHeight);
    
    GLdouble fx = -0.5f * fWidth;
    GLdouble fy = -0.5f * fHeight;
    
    m_Bounds[0] = CGRectMake(fx, fy, fWidth, fHeight);
    
    m_Bounds[1] = CGRectMake(-0.5f * kHUDLegendWidth,
                             -220.0f,
                             kHUDLegendWidth,
                             kHUDLegendHeight);
    
    m_Bounds[2] = CGRectMake(-0.5f * kHUDValueWidth,
                             -110.0f,
                             kHUDValueWidth,
                             kHUDValueHeight);
    
    mpQuad = GLU::QuadCreate(GL_DYNAMIC_DRAW);
    
    m_Texture[eHUDMeterBackground] = HUDBackgroundCreateTexture(mnWidth, mnHeight, mnMax);
    m_Texture[eHUDMeterNeedle]     = HUDNeedleCreateTexture(mnWidth, mnHeight);
    
    mpLegend = new (std::nothrow) GLU::Text(m_Legend,
                                            36.0f,
                                            false,
                                            GLsizei(kHUDLegendWidth),
                                            GLsizei(kHUDLegendHeight));
    
    if(mpLegend != nullptr)
    {
        m_Texture[eHUDMeterLegend] = mpLegend->texture();
    } // if
    else
    {
        NSLog(@">> ERROR: Failed an OpenGL text label for meter's legend!");
    } // else
} // Constructor

Image::~Image()
{
    if(m_Texture[eHUDMeterBackground])
    {
        glDeleteTextures(1, &m_Texture[eHUDMeterBackground]);
        
        m_Texture[eHUDMeterBackground] = 0;
    } // if
    
    if(m_Texture[eHUDMeterNeedle])
    {
        glDeleteTextures(1, &m_Texture[eHUDMeterNeedle]);
        
        m_Texture[eHUDMeterNeedle] = 0;
    } // if
    
    if(mpLegend != nullptr)
    {
        delete mpLegend;
        
        mpLegend = nullptr;
    } // if
    
    if(!m_Hash.empty())
    {
        GLU::Text *pText = nullptr;
        
        for(auto& text:m_Hash)
        {
            pText = text.second;
            
            if(pText != nullptr)
            {
                delete pText;
                
                pText = nullptr;
            } // if
        } // for
        
        m_Hash.clear();
    } // if
    
    GLU::QuadRelease(mpQuad);
    
    mpQuad = nullptr;
} // Destructor

const GLdouble Image::target() const
{
    return mnValue;
} // target

void Image::setTarget(const GLdouble& target)
{
    mnValue = target;
} // setTarget

void Image::reset()
{
    mnValue  = 0.0f;
    mnSmooth = 0.0f;
} // reset

void Image::update()
{
    // TODO: Move to time-based
    GLdouble step = mnLimit / 60.0f;
    
    if(std::fabs(mnSmooth - mnValue) < step)
    {
        mnSmooth = mnValue;
    } // if
    else if(mnValue > mnSmooth)
    {
        mnSmooth += step;
    } // else if
    else if(mnValue < mnSmooth)
    {
        mnSmooth -= step;
    } // else if
} // update

void Image::draw(const GLfloat& x,
                 const GLfloat& y)
{
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    {
        simd::float4x4 mv1 = GLM::modelview(true);
        
        simd::float4x4 translate = GLM::translate(x, y, 0.0f);
        
        GLM::load(true, mv1 * translate);
        
        glColor3f(1.0f, 1.0f, 1.0f);
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB);
        {
            glMatrixMode(GL_TEXTURE);
            
            simd::float4x4 tm = GLM::texture(true);
            
            GLM::load(true, GLM::scale(mnWidth, mnHeight, 1.0f));
            
            GLU::QuadSetIsInverted(false, mpQuad);
            GLU::QuadSetBounds(m_Bounds[0], mpQuad);
            
            if(!GLU::QuadIsFinalized(mpQuad))
            {
                GLU::QuadFinalize(mpQuad);
            } // if
            else
            {
                GLU::QuadUpdate(mpQuad);
            } // else
            
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, m_Texture[eHUDMeterBackground]);
            {
                GLU::QuadDraw(mpQuad);
                
                glBindTexture(GL_TEXTURE_RECTANGLE_ARB, m_Texture[eHUDMeterNeedle]);
                
                glMatrixMode(GL_MODELVIEW);
                
                simd::float4x4 mv2 = GLM::modelview(false);
                
                GLfloat angle = GLM::k180DivPi_f * HUDAngleForValue(mnSmooth, mnMax);
                
                simd::float4x4 rotate = GLM::rotate(angle, 0.0f, 0.0f, 1.0f);
                
                GLM::load(false, rotate * mv2);
                
                GLU::QuadDraw(mpQuad);
                
                GLM::load(false, mv2);
            }
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
            
            glMatrixMode(GL_TEXTURE);
            
            GLM::load(true, tm);
        }
        glDisable(GL_TEXTURE_RECTANGLE_ARB);
        
        glEnable(GL_TEXTURE_2D);
        {
            glBindTexture(GL_TEXTURE_2D, m_Texture[eHUDMeterLegend]);
            {
                GLU::QuadSetIsInverted(true, mpQuad);
                GLU::QuadSetBounds(m_Bounds[1], mpQuad);
                
                GLU::QuadUpdate(mpQuad);
                GLU::QuadDraw(mpQuad);
            }
            glBindTexture(GL_TEXTURE_2D, 0);
            
            GLuint nValue = GLuint(std::lrint(mnSmooth));
            GLuint nTex   = HUDEmplaceTextureWithLabel(nValue, m_Hash);
            
            if(nTex)
            {
                glBindTexture(GL_TEXTURE_2D, nTex);
                {
                    GLU::QuadSetIsInverted(true, mpQuad);
                    GLU::QuadSetBounds(m_Bounds[2], mpQuad);
                    
                    GLU::QuadUpdate(mpQuad);
                    GLU::QuadDraw(mpQuad);
                }
                glBindTexture(GL_TEXTURE_2D, 0);
            } // if
        }
        glDisable(GL_TEXTURE_2D);
        
        glMatrixMode(GL_MODELVIEW);
        
        GLM::load(true, mv1);
    }
    glDisable(GL_BLEND);
} // Draw