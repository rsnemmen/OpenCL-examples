/*
 <codex>
 <import>CGBitmap.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import "CGBitmap.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace CG;

#pragma mark -
#pragma mark Private - Utilities

static CGContextRef CGBitmapCreateFromImage(CGImageRef pImage)
{
    CGContextRef pContext = nullptr;
    
    if(pImage != nullptr)
    {
        CGColorSpaceRef pColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        
        if(pColorSpace != nullptr)
        {
            size_t       nWidth    = CGImageGetWidth(pImage);
            size_t       nHeight   = CGImageGetHeight(pImage);
            size_t       nRowBytes = 4 * nWidth;
            CGBitmapInfo nBMPI     = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            
            pContext = CGBitmapContextCreate(nullptr,
                                             nWidth,
                                             nHeight,
                                             8,
                                             nRowBytes,
                                             pColorSpace,
                                             nBMPI);
            
            if(pContext != nullptr)
            {
                CGContextDrawImage(pContext, CGRectMake(0, 0, nWidth, nHeight), pImage);
            } // if
            
            CFRelease(pColorSpace);
        } // if
    } // if
    
    return pContext;
} // CGBitmapCreateFromImage

static CGImageRef CGBitmapCreateImage(CFStringRef pName,
                                      CFStringRef pExt)
{
    CGImageRef pImage = nullptr;
    
    if((pName != nullptr) && (pExt != nullptr))
    {
        CFBundleRef pBundle = CFBundleGetMainBundle();
        
        if(pBundle != nullptr)
        {
            CFURLRef pURL = CFBundleCopyResourceURL(pBundle, pName, pExt, nullptr);
            
            if(pURL != nullptr)
            {
                CGImageSourceRef pSource = CGImageSourceCreateWithURL(pURL, nullptr);
                
                if(pSource != nullptr)
                {
                    pImage = CGImageSourceCreateImageAtIndex(pSource, 0, nullptr);
                    
                    CFRelease(pSource);
                } // if
                
                CFRelease(pURL);
            } // if
        } // if
    } // if
    
    return pImage;
} // CGBitmapCreateFromImage

static CGContextRef CGBitmapCreateCopy(const CGContextRef pContextSrc)
{
    CGContextRef pContextDst = nullptr;
    
    if(pContextSrc != nullptr)
    {
        CGImageRef pImage = CGBitmapContextCreateImage(pContextSrc);
        
        if(pImage != nullptr)
        {
            pContextDst = CGBitmapCreateFromImage(pImage);
            
            CFRelease(pImage);
        } // if
    } // if
    
    return pContextDst;
} // CGBitmapCreateCopy

#pragma mark -
#pragma mark Public - Interfaces

Bitmap::Bitmap(CFStringRef pName,
               CFStringRef pExt)
{
    mpContext  = nullptr;
    mnWidth    = 0;
    mnHeight   = 0;
    mnRowBytes = 0;
    mnBMPI     = 0;
    
    CGImageRef pImage = CGBitmapCreateImage(pName, pExt);
    
    if(pImage != nullptr)
    {
        mnWidth    = CGImageGetWidth(pImage);
        mnHeight   = CGImageGetHeight(pImage);
        mnRowBytes = 4 * mnWidth;
        mnBMPI     = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        mpContext  = CGBitmapCreateFromImage(pImage);
        
        CFRelease(pImage);
    } // if
} // Constructor

Bitmap::Bitmap(const Bitmap::Bitmap& rBitmap)
{
    mpContext = CGBitmapCreateCopy(rBitmap.mpContext);
    
    if(mpContext != nullptr)
    {
        mnWidth    = rBitmap.mnWidth;
        mnHeight   = rBitmap.mnHeight;
        mnRowBytes = rBitmap.mnRowBytes;
        mnBMPI     = rBitmap.mnBMPI;
    } // if
} // Copy Constructor

Bitmap::Bitmap(const Bitmap * const pBitmap)
{
    if(pBitmap != nullptr)
    {
        mpContext = CGBitmapCreateCopy(pBitmap->mpContext);
        
        if(mpContext != nullptr)
        {
            mnWidth    = pBitmap->mnWidth;
            mnHeight   = pBitmap->mnHeight;
            mnRowBytes = pBitmap->mnRowBytes;
            mnBMPI     = pBitmap->mnBMPI;
        } // if
    } // if
} // Copy Constructor

Bitmap::~Bitmap()
{
    CGContextRelease(mpContext);
} // Destructor

Bitmap& Bitmap::operator=(const Bitmap& rBitmap)
{
    if(this != &rBitmap)
    {
        CGContextRef pContext = CGBitmapCreateCopy(rBitmap.mpContext);
        
        if(pContext != nullptr)
        {
            CGContextRelease(mpContext);
            
            mnWidth    = rBitmap.mnWidth;
            mnHeight   = rBitmap.mnHeight;
            mnRowBytes = rBitmap.mnRowBytes;
            mnBMPI     = rBitmap.mnBMPI;
            mpContext  = pContext;
        } // if
    } // if
    
    return *this;
} // Operator =

bool Bitmap::copy(const CGContextRef pContext)
{
    bool bSuccess = pContext != nullptr;
    
    if(bSuccess)
    {
        size_t        nWidth    = CGBitmapContextGetWidth(pContext);
        size_t        nHeight   = CGBitmapContextGetHeight(pContext);
        size_t        nRowBytes = CGBitmapContextGetBytesPerRow(pContext);
        CGBitmapInfo  nBMPI     = CGBitmapContextGetBitmapInfo(pContext);
        
        bSuccess =
        ( nWidth    == mnWidth    )
        &&  ( nHeight   == mnHeight   )
        &&  ( nRowBytes == mnRowBytes )
        &&  ( nBMPI     == mnBMPI     );
        
        if(bSuccess)
        {
            const void *pDataSrc = CGBitmapContextGetData(pContext);
            
            void *pDataDst = CGBitmapContextGetData(mpContext);
            
            bSuccess = (pDataSrc != nullptr) && (pDataDst != nullptr);
            
            if(bSuccess)
            {
                const size_t nSize = mnRowBytes * mnHeight;
                
                std::memcpy(pDataDst, pDataSrc, nSize);
            } // if
        } // if
    } // if
    
    return bSuccess;
} // copy

const size_t& Bitmap::width() const
{
    return mnWidth;
} // width

const size_t& Bitmap::height() const
{
    return mnHeight;
} // height

const size_t& Bitmap::rowBytes() const
{
    return mnRowBytes;
} // rowBytes

const CGBitmapInfo& Bitmap::bitmapInfo() const
{
    return mnBMPI;
} // bitmapInfo

const CGContextRef Bitmap::context() const
{
    return mpContext;
} // context

void* Bitmap::data()
{
    void *pData = nullptr;
    
    if(mpContext != nullptr)
    {
        pData = CGBitmapContextGetData(mpContext);
    } // if
    
    return pData;
} // data
