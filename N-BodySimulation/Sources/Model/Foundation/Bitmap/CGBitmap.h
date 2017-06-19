/*
 <codex>
 <abstract>
 Utility methods acquiring CG bitmap contexts.
 </abstract>
 </codex>
 */

#ifndef _CORE_GRAPHICS_BITMAP_H_
#define _CORE_GRAPHICS_BITMAP_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#ifdef __cplusplus

namespace CG
{
    class Bitmap
    {
    public:
        Bitmap(CFStringRef pName,
               CFStringRef pExt);
        
        Bitmap(const Bitmap& rBitmap);
        Bitmap(const Bitmap * const pBitmap);
        
        virtual ~Bitmap();
        
        Bitmap& operator=(const Bitmap& rBitmap);

        const size_t& width()    const;
        const size_t& height()   const;
        const size_t& rowBytes() const;
        
        const CGContextRef context() const;

        const CGBitmapInfo& bitmapInfo() const;

        bool copy(const CGContextRef pContext);
        
        void* data();

    private:
        size_t        mnWidth;
        size_t        mnHeight;
        size_t        mnRowBytes;
        CGBitmapInfo  mnBMPI;
        CGContextRef  mpContext;
    }; // Bitmap
} // CG

#endif

#endif

