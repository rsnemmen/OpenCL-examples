/*
 <codex>
 <abstract>
 Utility methods for generating OpenGL texture from a string.
 </abstract>
 </codex>
 */

#ifndef _OPENGL_UTILITY_TEXT_H_
#define _OPENGL_UTILITY_TEXT_H_

#import <string>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "CTFrame.h"
#import "GLcontainers.h"

#ifdef __cplusplus

namespace GLU
{
    class Text
    {
    public:
        // Create a texture with bounds derived from the text size.
        Text(const GLstring& rText,
             const GLstring& rFont,
             const GLfloat& nFontSize,
             const CGPoint& rOrigin,
             const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        // Create a texture with bounds derived from the input width and height.
        Text(const GLstring& rText,
             const GLstring& rFont,
             const GLfloat& nFontSize,
             const GLsizei& nWidth,
             const GLsizei& nHeight,
             const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        // Create a texture with bounds derived from the text size using
        // helvetica bold or helvetica bold oblique font.
        Text(const GLstring& rText,
             const CGFloat& nFontSize,
             const bool& bIsItalic,
             const CGPoint& rOrigin,
             const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        // Create a texture with bounds derived from input width and height,
        // and using helvetica bold or helvetica bold oblique font.
        Text(const GLstring& rText,
             const CGFloat& nFontSize,
             const bool& bIsItalic,
             const GLsizei& nWidth,
             const GLsizei& nHeight,
             const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        virtual ~Text();
        
        const GLuint&  texture() const;
        const CGRect&  bounds()  const;
        const CFRange& range()   const;
        
    private:
        CGContextRef create(const GLsizei& nWidth,
                            const GLsizei& nHeight);
        
        CGContextRef create(const CGSize& rSize);
        
        GLuint create(CGContextRef pContext);
        
        GLuint create(const GLstring& rText,
                      const GLstring& rFont,
                      const GLfloat& nFontSize,
                      const CGPoint& rOrigin,
                      const CTTextAlignment& nTextAlign);
        
        GLuint create(const GLstring& rText,
                      const GLstring& rFont,
                      const GLfloat& nFontSize,
                      const GLsizei& nWidth,
                      const GLsizei& nHeight,
                      const CTTextAlignment& nTextAlign);
        
    private:
        GLuint   mnTexture;
        CGRect   m_Bounds;
        CFRange  m_Range;
    }; // Text
} // GLU

#endif

#endif


