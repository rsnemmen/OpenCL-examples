/*
 <codex>
 <import>CFText.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Headers

// CF mutable attributed string utilities
#import "CFText.h"

#pragma mark -
#pragma mark Private - Constants

// Size constants
static const uint32_t CFTextSizeCTTextAlignment = sizeof(CTTextAlignment);
static const uint32_t CFTextSizeCGFloat         = sizeof(CGFloat);

// Array counts
static const uint32_t CFTextAttribsCount = 3;
static const uint32_t CFTextStyleCount   = 2;

#pragma mark -
#pragma mark Private - utilities - CF Strings

static CFStringRef CFStringCreate(const std::string& rString)
{
    CFStringRef pString = nullptr;
    
    if(!rString.empty())
    {
        pString = CFStringCreateWithCString(kCFAllocatorDefault,
                                            rString.data(),
                                            kCFStringEncodingUTF8);
    } // if
    
    return pString;
} // CFStringCreate

#pragma mark -
#pragma mark Private - utilities - Paragraph Styles

// Create alignment paragraph setting
static CTParagraphStyleSetting CFTextCreateParagraphSettingAlignment(const CTTextAlignment *pAlignment)
{
    CTParagraphStyleSetting setting =
    {
        kCTParagraphStyleSpecifierAlignment,
        CFTextSizeCTTextAlignment,
        pAlignment
    };
    
    // Create a paragraph style
    return setting;
} // CFTextCreateParagraphSettingAlignment

// Create line height paragraph setting
static CTParagraphStyleSetting CFTextCreateParagraphSettingLineHeight(const CGFloat *pLineHeight)
{
    CTParagraphStyleSetting setting =
    {
        kCTParagraphStyleSpecifierLineHeightMultiple,
        CFTextSizeCGFloat,
        pLineHeight
    };
    
    return setting;
} // CFTextCreateParagraphSettingLineHeight

// Create a paragraph style with line height and alignment
static CTParagraphStyleRef CFTextCreateParagraphStyle(const CGFloat& nLineHeight,
                                                      const CTTextAlignment& nAlignment)
{
    CTParagraphStyleSetting alignment  = CFTextCreateParagraphSettingAlignment(&nAlignment);
    CTParagraphStyleSetting lineHeight = CFTextCreateParagraphSettingLineHeight(&nLineHeight);
    
    // Paragraph settings with alignment and style
    CTParagraphStyleSetting settings[CFTextStyleCount] = {alignment, lineHeight};
    
    // Create a paragraph style
    return CTParagraphStyleCreate(settings, CFTextStyleCount);
} // CFTextCreateParagraphStyle

#pragma mark -
#pragma mark Private - utilities - Fonts

// Create a font with name and size
static CTFontRef CFTextCreateFont(CFStringRef pFontNameSrc,
                                  const CGFloat& nFontSizeSrc)
{
    // Minimum sizeis 4 pts.
    CGFloat nFontSizeDst = (nFontSizeSrc > 4.0) ? nFontSizeSrc : 4.0;
    
    // If the font name is null default to Helvetica
    CFStringRef pFontNameDst = (pFontNameSrc) ? pFontNameSrc : CFSTR("Helvetica");
    
    // Prepare font
    return CTFontCreateWithName(pFontNameDst, nFontSizeDst, nullptr);
} // CFTextCreateFont

// Create a font with name and size
static CTFontRef CFTextCreateFont(const std::string& rFontNameSrc,
                                  const CGFloat& nFontSizeSrc)
{
    CTFontRef pFont = nullptr;
    
    // If the font name is null default to Helvetica
    std::string rFontNameDst = (!rFontNameSrc.empty()) ? rFontNameSrc : "Helvetica";
    
    // Create a cf string representing a font name
    CFStringRef pFontName = CFStringCreate(rFontNameDst);
    
    if( pFontName != nullptr )
    {
        // Create a font reference with name and size
        pFont = CFTextCreateFont(pFontName, nFontSizeSrc);
        
        // Release the font name
        CFRelease(pFontName);
    } // if
    
    return pFont;
} // CFTextCreateFont

#pragma mark -
#pragma mark Private - utilities - Colors

// Return a color reference if valid, else get the clear color
static CGColorRef CFTextGetColor(CGColorRef pColor)
{
    return (pColor) ? pColor : CGColorGetConstantColor(kCGColorClear);
} // CFTextGetColor

// Return a color reference if valid, else get the clear color
static CGColorRef CFTextCreateColor(const CGFloat * const pComponents)
{
    return (pComponents)
    ? CGColorCreateGenericRGB(pComponents[0], pComponents[1], pComponents[2], pComponents[3])
    : CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
} // CFTextGetColor

#pragma mark -
#pragma mark Private - utilities - Attributes

// Create an attributes dictionary with paragraph style, font, and colors
static CFDictionaryRef CFTextCreateAttributes(CTParagraphStyleRef pStyle,
                                              CTFontRef pFont,
                                              const CGColorRef pColor)
{
    // Dictionary Keys
    CFStringRef keys[CFTextAttribsCount] =
    {
        kCTParagraphStyleAttributeName,
        kCTFontAttributeName,
        kCTForegroundColorAttributeName
    };
    
    // Dictionary Values
    CFTypeRef values[CFTextAttribsCount] =
    {
        pStyle,
        pFont,
        pColor
    };
    
    // Create a dictionary of attributes for our string
    return CFDictionaryCreate(nullptr,
                              (const void **)&keys,
                              (const void **)&values,
                              CFTextAttribsCount,
                              &kCFTypeDictionaryKeyCallBacks,
                              &kCFTypeDictionaryValueCallBacks);
} // CFTextCreateAttributes

#pragma mark -
#pragma mark Private - utilities - Mutable Attributed Strings

// Creating a mutable attributed string from a cf string and
// an dictionary of attributes.
static CF::TextRef CFTextCreate(CFStringRef pString,
                                CFDictionaryRef pAttributes)
{
    // Creating a mutable attributed string
    CF::TextRef pText = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    if( pText != nullptr )
    {
        // Set a mutable attributed string with the input string
        CFAttributedStringReplaceString(pText, CFRangeMake(0, 0), pString);
        
        // Compute the mutable attributed string range
        CFRange range = CFRangeMake(0, CFAttributedStringGetLength(pText));
        
        // Set the attributes
        CFAttributedStringSetAttributes(pText, range, pAttributes, NO);
    } // if
    
    return pText;
} // CFTextCreate

// Create an attributed string from a CF string, font, justification, and font size
static CF::TextRef CFTextCreate(CFStringRef pString,
                                CTFontRef pFont,
                                const CGFloat& nLineHeight,
                                const CTTextAlignment& nAlignment,
                                const CGColorRef pColor)
{
    CF::TextRef pText = nullptr;
	
    // Create a paragraph style
    CTParagraphStyleRef pStyle = CFTextCreateParagraphStyle(nLineHeight, nAlignment);
    
    if( pStyle != nullptr )
    {
        // Create a dictionary of attributes for our string
        CFDictionaryRef pAttributes = CFTextCreateAttributes(pStyle, pFont, pColor);
        
        if( pAttributes != nullptr )
        {
            // Creating a mutable attributed string
            pText = CFTextCreate(pString, pAttributes);
            
            // Relase the attributes
            CFRelease(pAttributes);
        } // if
        
        // Release the paragraph style
        CFRelease(pStyle);
    } // if
    
    return pText;
} // CFTextCreate

#pragma mark -
#pragma mark Public - Constructors

// Create an attributed string from a CF string, font, justification, and font size
CF::TextRef CF::TextCreate(CFStringRef pString,
                           CFStringRef pFontName,
                           const CGFloat& nFontSize,
                           const CGFloat& nLineHeight,
                           const CTTextAlignment& nAlignment,
                           CGColorRef pComponents)
{
    CF::TextRef pText = nullptr;
    
    if( pString != nullptr )
    {
        // Create a font reference
        CTFontRef pFont = CFTextCreateFont(pFontName, nFontSize);
        
        if( pFont != nullptr )
        {
            // If null color components then default to the constant clear color
            CGColorRef pColor = CFTextGetColor(pComponents);
            
            // Creating a mutable attributed string
            pText = CFTextCreate(pString,
                                 pFont,
                                 nLineHeight,
                                 nAlignment,
                                 pColor);
            
            // Release the font reference
            CFRelease(pFont);
        } // if
    } // if
    
    return pText;
} // CFTextCreate

// Create an attributed string from a CF string, font, justification, and font size
CF::TextRef CF::TextCreate(CFStringRef pString,
                           CFStringRef pFontName,
                           const CGFloat& nFontSize,
                           const CTTextAlignment& nAlignment)
{
    return CF::TextCreate(pString, pFontName, nFontSize, 1.0f, nAlignment, nullptr);
} // CFTextCreate

// Create an attributed string from a stl string, font, justification, and font size
CF::TextRef CF::TextCreate(const std::string& rString,
                           const std::string& rFontName,
                           const CGFloat& nFontSize,
                           const CGFloat& nLineHeight,
                           const CTTextAlignment& nAlignment,
                           const CGFloat * const pComponents)
{
    CF::TextRef pText = nullptr;
    
    // Create a string reference from a stl string
    CFStringRef pString = CFStringCreate(rString);
    
    if( pString != nullptr )
    {
        // Create a font reference
        CTFontRef pFont = CFTextCreateFont(rFontName, nFontSize);
        
        if( pFont != nullptr )
        {
            // Create a white color reference
            CGColorRef pColor = CFTextCreateColor(pComponents);
            
            if( pColor != nullptr )
            {
                // Create a mutable attributed string
                pText = CFTextCreate(pString,
                                     pFont,
                                     nLineHeight,
                                     nAlignment,
                                     pColor);
                
                // Release the color reference
                CFRelease(pColor);
            } // if
            
            // Release the font reference
            CFRelease(pFont);
        } // if
        
        // Release the string reference
        CFRelease(pString);
    } // if
    
    return pText;
} // CFTextCreate

// Create an attributed string from a stl string, font, justification, and font size
CF::TextRef CF::TextCreate(const std::string& rString,
                           const std::string& rFontName,
                           const CGFloat& nFontSize,
                           const CTTextAlignment& nAlignment)
{
    return CF::TextCreate(rString, rFontName, nFontSize, 1.0f, nAlignment, nullptr);
} // CFTextCreate

// If not nullptr then make a deep-copy of mutable attributed string reference
CF::TextRef CF::TextCreateCopy(CFAttributedStringRef pAttrString)
{
    CF::TextRef pText = nullptr;
    
    if(pAttrString != nullptr)
    {
        CFIndex nMaxLength = CFAttributedStringGetLength(pAttrString);
        
        if(nMaxLength)
        {
            pText = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, nMaxLength, pAttrString);
        } // if
    } // if
    
    return pText;
} // CFTextCreateCopy

// If not nullptr then make a deep-copy of mutable attributed string reference
CF::TextRef CF::TextCreateCopy(CF::TextRef pTextSrc)
{
    CF::TextRef pTextDst = nullptr;
    
    if(pTextSrc != nullptr)
    {
        CFIndex nMaxLength = CFAttributedStringGetLength(pTextSrc);
        
        if(nMaxLength)
        {
            pTextDst = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, nMaxLength, pTextSrc);
        } // if
    } // if
    
    return pTextDst;
} // if

// If not nullptr then retain a copy of mutable attributed string reference
CF::TextRef CF::TextRetain(CF::TextRef pText)
{
    CF::TextRef pTextCopy = nullptr;
    
    if(pText != nullptr)
    {
        CFRetain(pText);
        
        pTextCopy = pText;
    } // if
    
    return pTextCopy;
} // CFTextRetain

// If not nullptr then release the mutable attributed string reference
void CF::TextRelease(CF::TextRef pText)
{
    if(pText != nullptr)
    {
        CFRelease(pText);
        
        pText = nullptr;
    } // if
} // CFTextRelease