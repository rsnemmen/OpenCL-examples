/*
 <codex>
 <abstract>
 Utility calss for generating frames from attributed strings.
 </abstract>
 </codex>
 */

#ifndef _CORE_TEXT_FRAME_H_
#define _CORE_TEXT_FRAME_H_

#import <string>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#ifdef __cplusplus

namespace CT
{
    class Frame
    {
    public:
        // Create a frame with bounds derived from the text size.
        Frame(const std::string& rText,
              const std::string& rFont,
              const GLfloat& nFontSize,
              const CGPoint& rOrigin,
              const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        // Create a frame with bounds derived from the input width and height.
        Frame(const std::string& rText,
              const std::string& rFont,
              const GLfloat& nFontSize,
              const GLsizei& nWidth,
              const GLsizei& nHeight,
              const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        // Create a frame with bounds derived from the text size using
        // helvetica bold or helvetica bold oblique font.
        Frame(const std::string& rText,
              const CGFloat& nFontSize,
              const bool& bIsItalic,
              const CGPoint& rOrigin,
              const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        // Create a frame with bounds derived from input width and height,
        // and using helvetica bold or helvetica bold oblique font.
        Frame(const std::string& rText,
              const CGFloat& nFontSize,
              const bool& bIsItalic,
              const GLsizei& nWidth,
              const GLsizei& nHeight,
              const CTTextAlignment& nTextAlign = kCTTextAlignmentCenter);
        
        virtual ~Frame();
        
        const CGRect&  bounds() const;
        const CFRange& range()  const;
        
        void draw(CGContextRef pContext);
        
    private:
        void defaults();
        
        CTFramesetterRef create(const std::string& rText,
                                const std::string& rFont,
                                const GLfloat& nFontSize,
                                const CTTextAlignment& nTextAlign);
        
        CTFrameRef create(CTFramesetterRef pFrameSetter);
        
        CTFrameRef create(const CGPoint& rOrigin,
                          const CGSize& rSize,
                          CTFramesetterRef pFrameSetter);
        
        CTFrameRef create(const GLsizei& nWidth,
                          const GLsizei& nHeight,
                          CTFramesetterRef pFrameSetter);
        
        CTFrameRef create(const std::string& rText,
                          const std::string& rFont,
                          const GLfloat& nFontSize,
                          const CGPoint& rOrigin,
                          const CTTextAlignment& nTextAlign);
        
        CTFrameRef create(const std::string& rText,
                          const std::string& rFont,
                          const GLfloat& nFontSize,
                          const GLsizei& nWidth,
                          const GLsizei& nHeight,
                          const CTTextAlignment& nTextAlign);
        
    private:
        CTFrameRef mpFrame;
        CFRange    m_Range;
        CGRect     m_Bounds;
    }; // Frame
} // CT

#endif

#endif


