/*
 <codex>
 <import>GLUText.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <OpenGL/gl.h>

#import "CFText.h"
#import "CTFrame.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace CT;

#pragma mark -
#pragma mark Private - Constants

static const CGSize  kCTFrameDefaultMaxSz = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);

#pragma mark -
#pragma mark Private - Utilities - Constructor - Framesetter

CTFramesetterRef Frame::create(const std::string& rText,
                               const std::string& rFont,
                               const GLfloat& nFontSize,
                               const CTTextAlignment& nTextAlign)
{
    CTFramesetterRef pFrameSetter = nullptr;
    
    CF::TextRef pText = CF::TextCreate(rText, rFont, nFontSize, nTextAlign);
    
    if(pText != nullptr)
    {
        m_Range = CFRangeMake(0, CFAttributedStringGetLength(pText));
        
        pFrameSetter = CTFramesetterCreateWithAttributedString(pText);
        
        CFRelease(pText);
    } // if
    
    return pFrameSetter;
} // create

#pragma mark -
#pragma mark Private - Utilities - Constructors - Frames

CTFrameRef Frame::create(CTFramesetterRef pFrameSetter)
{
    CTFrameRef pFrame = nullptr;
    
    if(pFrameSetter != nullptr)
    {
        CGMutablePathRef pPath = CGPathCreateMutable();
        
        if(pPath != nullptr)
        {
            CGPathAddRect(pPath, nullptr, m_Bounds);
            
            pFrame = CTFramesetterCreateFrame(pFrameSetter,
                                              m_Range,
                                              pPath,
                                              nullptr);
            
            CFRelease(pPath);
        } // if
    } // if
    
    return pFrame;
} // create

CTFrameRef Frame::create(const CGPoint& rOrigin,
                         const CGSize& rSize,
                         CTFramesetterRef pFrameSetter)
{
    m_Bounds = CGRectMake(rOrigin.x,
                          rOrigin.y,
                          rSize.width,
                          rSize.height);
    
    return create(pFrameSetter);
} // create

CTFrameRef Frame::create(const GLsizei& nWidth,
                         const GLsizei& nHeight,
                         CTFramesetterRef pFrameSetter)
{
    m_Bounds = CGRectMake(0.0f,
                          0.0f,
                          CGFloat(nWidth),
                          CGFloat(nHeight));
    
    return create(pFrameSetter);
} // create

CTFrameRef Frame::create(const std::string& rText,
                         const std::string& rFont,
                         const GLfloat& nFontSize,
                         const CGPoint& rOrigin,
                         const CTTextAlignment& nTextAlign)
{
    CTFrameRef pFrame = nullptr;
    
    if(!rText.empty())
    {
        CTFramesetterRef pFrameSetter = create(rText, rFont, nFontSize, nTextAlign);
        
        if(pFrameSetter != nullptr)
        {
            CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(pFrameSetter,
                                                                       m_Range,
                                                                       nullptr,
                                                                       kCTFrameDefaultMaxSz,
                                                                       nullptr);
            
            pFrame = create(rOrigin, size, pFrameSetter);
            
            CFRelease(pFrameSetter);
        } // if
    } // if
    
    return pFrame;
} // create

CTFrameRef Frame::create(const std::string& rText,
                         const std::string& rFont,
                         const GLfloat& nFontSize,
                         const GLsizei& nWidth,
                         const GLsizei& nHeight,
                         const CTTextAlignment& nTextAlign)
{
    CTFrameRef pFrame = nullptr;
    
    if(!rText.empty())
    {
        CTFramesetterRef pFrameSetter = create(rText, rFont, nFontSize, nTextAlign);
        
        if(pFrameSetter != nullptr)
        {
            pFrame = create(nWidth, nHeight, pFrameSetter);
            
            CFRelease(pFrameSetter);
        } // if
    } // if
    
    return pFrame;
} // draw

#pragma mark -
#pragma mark Private - Utilities - Defaults

void Frame::defaults()
{
    mpFrame  = nullptr;
    m_Range  = CFRangeMake(0, 0);
    m_Bounds = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
} // defaults

#pragma mark -
#pragma mark Public - Constructors

// Create a frame with bounds derived from the text size.
Frame::Frame(const std::string& rText,
             const std::string& rFont,
             const GLfloat& nFontSize,
             const CGPoint& rOrigin,
             const CTTextAlignment& nTextAlign)
{
    mpFrame = create(rText, rFont, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a frame with bounds derived from the input width and height.
Frame::Frame(const std::string& rText,
             const std::string& rFont,
             const GLfloat& nFontSize,
             const GLsizei& nWidth,
             const GLsizei& nHeight,
             const CTTextAlignment& nTextAlign)
{
    mpFrame = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

// Create a frame with bounds derived from the text size using
// helvetica bold or helvetica bold oblique font.
Frame::Frame(const std::string& rText,
             const CGFloat& nFontSize,
             const bool& bIsItalic,
             const CGPoint& rOrigin,
             const CTTextAlignment& nTextAlign)
{
    std::string font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mpFrame = create(rText, font, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a frame with bounds derived from input width and height,
// and using helvetica bold or helvetica bold oblique font.
Frame::Frame(const std::string& rText,
             const CGFloat& nFontSize,
             const bool& bIsItalic,
             const GLsizei& nWidth,
             const GLsizei& nHeight,
             const CTTextAlignment& nTextAlign)
{
    std::string font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mpFrame = create(rText, font, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Frame::~Frame()
{
    if(mpFrame != nullptr)
    {
        CFRelease(mpFrame);
        
        mpFrame = nullptr;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Utlities

void Frame::draw(CGContextRef pContext)
{
    if(pContext != nullptr)
    {
        CTFrameDraw(mpFrame, pContext);
    } // if
} // draw

#pragma mark -
#pragma mark Public - Accessors

const CGRect& Frame::bounds() const
{
    return m_Bounds;
} // bounds

const CFRange& Frame::range() const
{
    return m_Range;
} // range
