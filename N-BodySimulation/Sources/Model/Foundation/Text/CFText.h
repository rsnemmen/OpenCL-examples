/*
 <codex>
 <abstract>
 Utility toolkit for managing mutable attributed strings.
 </abstract>
 </codex>
 */

// MacOS X

#ifndef _CORE_FOUNDATION_TEXT_H_
#define _CORE_FOUNDATION_TEXT_H_

// STL string
#import <string>

// Mac OS X frameworks
#import <Cocoa/Cocoa.h>

#ifdef __cplusplus

namespace CF
{
    // Text reference type definition representing a CF mutable attributed string
    // opaque data reference
    typedef CFMutableAttributedStringRef  TextRef;
    
    // Create an attributed string from a stl string, font, justification, and font size
    TextRef TextCreate(const std::string& rString,
                       const std::string& rFontName,
                       const CGFloat& nFontSize,
                       const CTTextAlignment& nAlignment);
    
    // Create an attributed string from a stl string, font, justification, and font size
    TextRef TextCreate(const std::string& rString,
                       const std::string& rFontName,
                       const CGFloat& nFontSize,
                       const CGFloat& nLineHeight,
                       const CTTextAlignment& nAlignment,
                       const CGFloat * const pComponents);
    
    // Create an attributed string from a CF string, font, justification, and font size
    TextRef TextCreate(CFStringRef pString,
                       CFStringRef pFontName,
                       const CGFloat& nFontSize,
                       const CTTextAlignment& nAlignment);
    
    // Create an attributed string from a CF string, font, justification, and font size
    TextRef TextCreate(CFStringRef pString,
                       CFStringRef pFontName,
                       const CGFloat& nFontSize,
                       const CGFloat& nLineHeight,
                       const CTTextAlignment& nAlignment,
                       CGColorRef pComponents);
    
    // If not nullptr then make a deep-copy of an attributed string reference
    TextRef TextCreateCopy(CFAttributedStringRef pAttrString);
    
    // If not nullptr then make a deep-copy of mutable attributed string reference
    TextRef TextCreateCopy(TextRef pText);
    
    // If not nullptr then retain a copy of mutable attributed string reference
    TextRef TextRetain(TextRef pText);
    
    // If not nullptr then release the mutable attributed string reference
    void TextRelease(TextRef pText);
} // CF

#endif

#endif
