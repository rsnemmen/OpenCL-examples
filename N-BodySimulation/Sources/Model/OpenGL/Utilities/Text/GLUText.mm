/*
 <codex>
 <import>GLUText.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <OpenGL/gl.h>

#import "CFText.h"

#import "GLUText.h"

#pragma mark -
#pragma mark Private - Constants

static const GLuint kGLUTextBPC = 8;
static const GLuint kGLUTextSPP = 4;

static const CGBitmapInfo kGLUTextBitmapInfo = kCGImageAlphaPremultipliedLast;

#pragma mark -
#pragma mark Private - Utilities - Constructors - Contexts

CGContextRef GLU::Text::create(const GLsizei& nWidth,
                               const GLsizei& nHeight)
{
    CGContextRef pContext = nullptr;
    
    if(nWidth * nHeight)
    {
        CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        
        if(pColorspace != nullptr)
        {
            const size_t bpp = nWidth * kGLUTextSPP;
            
            pContext = CGBitmapContextCreate(nullptr,
                                             nWidth,
                                             nHeight,
                                             kGLUTextBPC,
                                             bpp,
                                             pColorspace,
                                             kGLUTextBitmapInfo);
            
            if(pContext != nullptr)
            {
                CGContextSetShouldAntialias(pContext, true);
            } // if
            
            CFRelease(pColorspace);
        } // if
    } // if
    
    return pContext;
} // create

CGContextRef GLU::Text::create(const CGSize& rSize)
{
    return create(GLsizei(rSize.width), GLsizei(rSize.height));
} // create

#pragma mark -
#pragma mark Private - Utilities - Constructors - Texturers

GLuint GLU::Text::create(CGContextRef pContext)
{
    GLuint texture = 0;
    
    glGenTextures(1, &texture);
    
    if(texture)
    {
        glBindTexture(GL_TEXTURE_2D, texture);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        const GLsizei  width  = GLsizei(CGBitmapContextGetWidth(pContext));
        const GLsizei  height = GLsizei(CGBitmapContextGetHeight(pContext));
        const void*    pData  = CGBitmapContextGetData(pContext);
        
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RGBA,
                     width,
                     height,
                     0,
                     GL_RGBA,
                     GL_UNSIGNED_BYTE,
                     pData);
    } // if
    
    return texture;
} // create

GLuint GLU::Text::create(const GLstring& rText,
                         const GLstring& rFont,
                         const GLfloat& nFontSize,
                         const CGPoint& rOrigin,
                         const CTTextAlignment& nTextAlign)
{
    GLuint nTexture = 0;
    
    CT::Frame* pFrame = new (std::nothrow) CT::Frame(rText, rFont, nFontSize, rOrigin, nTextAlign);

    if(pFrame != nullptr)
    {
        m_Bounds = pFrame->bounds();
        m_Range  = pFrame->range();

        CGContextRef pContext = create(m_Bounds.size);
        
        if(pContext != nullptr)
        {
            pFrame->draw(pContext);
            
            nTexture = create(pContext);
            
            CFRelease(pContext);
        } // if
        
        delete pFrame;
    } // if
    else
    {
        NSLog(@">> ERROR: Failed creating Core-Text frame object!");
    } // else
    
    return nTexture;
} // create

GLuint GLU::Text::create(const GLstring& rText,
                         const GLstring& rFont,
                         const GLfloat& nFontSize,
                         const GLsizei& nWidth,
                         const GLsizei& nHeight,
                         const CTTextAlignment& nTextAlign)
{
    GLuint nTexture = 0;
    
    CT::Frame* pFrame = new CT::Frame(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign);

    if(pFrame != nullptr)
    {
        m_Bounds = pFrame->bounds();
        m_Range  = pFrame->range();
        
        CGContextRef pContext = create(nWidth, nHeight);
        
        if(pContext != nullptr)
        {
            pFrame->draw(pContext);
            
            nTexture = create(pContext);
            
            CFRelease(pContext);
        } // if
        
        delete pFrame;
    } // if
    else
    {
        NSLog(@">> ERROR: Failed creating Core-Text frame object!");
    } // else

    return nTexture;
} // create

#pragma mark -
#pragma mark Public - Constructors

// Create a texture with bounds derived from the text size.
GLU::Text::Text(const GLstring& rText,
                const GLstring& rFont,
                const GLfloat& nFontSize,
                const CGPoint& rOrigin,
                const CTTextAlignment& nTextAlign)
{
    mnTexture = create(rText, rFont, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a texture with bounds derived from the input width and height.
GLU::Text::Text(const GLstring& rText,
                const GLstring& rFont,
                const GLfloat& nFontSize,
                const GLsizei& nWidth,
                const GLsizei& nHeight,
                const CTTextAlignment& nTextAlign)
{
    mnTexture = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

// Create a texture with bounds derived from the text size using
// helvetica bold or helvetica bold oblique font.
GLU::Text::Text(const GLstring& rText,
                const CGFloat& nFontSize,
                const bool& bIsItalic,
                const CGPoint& rOrigin,
                const CTTextAlignment& nTextAlign)
{
    GLstring font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mnTexture = create(rText, font, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a texture with bounds derived from input width and height,
// and using helvetica bold or helvetica bold oblique font.
GLU::Text::Text(const GLstring& rText,
                const CGFloat& nFontSize,
                const bool& bIsItalic,
                const GLsizei& nWidth,
                const GLsizei& nHeight,
                const CTTextAlignment& nTextAlign)
{
    GLstring font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mnTexture = create(rText, font, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

GLU::Text::~Text()
{
    if(mnTexture)
    {
        glDeleteTextures(1, &mnTexture);
        
        mnTexture = 0;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLuint& GLU::Text::texture() const
{
    return mnTexture;
} // texture

const CGRect& GLU::Text::bounds() const
{
    return m_Bounds;
} // bounds

const CFRange& GLU::Text::range() const
{
    return m_Range;
} // range
