/*
 <codex>
 <import>CFFile.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import "CFFile.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace CF;

#pragma mark -
#pragma mark Private - Type Definitions

typedef NSArray*  NSArrayRef;
typedef NSString* NSStringRef;

#pragma mark -
#pragma mark Private - Utilities - Files

static bool CFFileGetFileSize(CFURLRef pURL,
                              CFIndex* pFileSize)
{
    CFErrorRef  pError = nullptr;
    CFNumberRef pSize  = nullptr;
    
    bool bSuccess = CFURLCopyResourcePropertyForKey(pURL,
                                                    kCFURLFileSizeKey,
                                                    &pSize,
                                                    &pError);
    
    if(bSuccess)
    {
        bSuccess = CFNumberGetValue(pSize, kCFNumberSInt64Type, pFileSize);
        
        if(!bSuccess)
        {
            *pFileSize = 0;
        } // if
    } // if
    
    if(pSize != nullptr)
    {
        CFRelease(pSize);
    } // if
    
    return bSuccess;
} // CFFileGetFileSize

static CFIndex CFFileAcquire(const CFIndex& nSize,
                             UInt8* pBuffer,
                             CFURLRef pURL)
{
    CFIndex          nLength = 0;
    CFReadStreamRef  pStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, pURL);
    
    if(pStream != nullptr)
    {
        if(CFReadStreamOpen(pStream))
        {
            nLength = CFReadStreamRead(pStream, pBuffer, nSize);
            
            CFReadStreamClose(pStream);
        } // if
        
        CFRelease(pStream);
    } // if
    
    return nLength;
} // CFFileAcquire

static UInt8* CFFileCreateBuffer(CFIndex& nLength,
                                 CFURLRef pURL)
{
    CFIndex  nSize   = 0;
    UInt8*   pBuffer = nullptr;
    
    if(CFFileGetFileSize(pURL, &nSize))
    {
        pBuffer = (UInt8 *)calloc(nSize, sizeof(UInt8));
        
        if(pBuffer != nullptr)
        {
            CFIndex nReadSz = CFFileAcquire(nSize, pBuffer, pURL);
            
            nLength = (nReadSz == nSize) ? nReadSz : -1;
        } // if
    } // if
    
    return pBuffer;
} // CFFileCreateBuffer

static CFDataRef CFFileCreate(CFURLRef pURL)
{
    CFDataRef pData = nullptr;
    
    if(pURL != nullptr)
    {
        CFIndex  nLength = 0;
        UInt8*   pBuffer = CFFileCreateBuffer(nLength, pURL);
        
        if(pBuffer != nullptr)
        {
            pData = CFDataCreate(kCFAllocatorDefault,
                                 pBuffer,
                                 nLength);
            
            free(pBuffer);
        } // if
    } // if
    
    return pData;
} // CFFileCreate

#pragma mark -
#pragma mark Private - Utilities - URLs

static CFURLRef CFFileCreateURL(CFStringRef pPathname)
{
    CFURLRef pURL = nullptr;
    
    if(pPathname != nullptr)
    {
        pURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, pPathname, kCFURLPOSIXPathStyle, false);
    } // if
    
    return pURL;
} // CFFileCreateURL

static CFURLRef CFFileCreateURL(CFStringRef pName,
                                CFStringRef pExt)
{
    CFURLRef pURL = nullptr;
    
    if(pName != nullptr)
    {
        CFBundleRef pBundle = CFBundleGetMainBundle();
        
        if(pBundle != nullptr)
        {
            pURL = CFBundleCopyResourceURL(pBundle, pName, pExt, nullptr);
        } // if
    } // if
    
    return pURL;
} // CFFileCreate

static CFURLRef CFFileCreateURL(const CFSearchPathDomainMask& domain,
                                const CFSearchPathDirectory& directory,
                                CFStringRef pDirName,
                                CFStringRef pFileName,
                                CFStringRef pFileExt)
{
    CFURLRef pURL = nullptr;
    
    if(pFileName && pDirName)
    {
        CFArrayRef pLibPaths = CFArrayRef(NSSearchPathForDirectoriesInDomains(directory, domain, YES));
        
        if(pLibPaths != nullptr)
        {
            
            CFStringRef pDirPath   = CFStringRef(CFArrayGetValueAtIndex(pLibPaths, 0));
            CFStringRef pValues[3] = {pDirPath, pDirName, pFileName};
            
            CFArrayRef pComponents = CFArrayCreate(kCFAllocatorDefault,
                                                   (const void **)&pValues,
                                                   3,
                                                   &kCFTypeArrayCallBacks);
            
            if(pComponents)
            {
                CFStringRef pPathname = CFStringCreateByCombiningStrings(kCFAllocatorDefault,
                                                                         pComponents,
                                                                         CFSTR("/"));
                
                if(pPathname)
                {
                    if(pFileExt != nullptr)
                    {
                        CFStringRef pFormat = CFSTR("%@.%@");
                        
                        CFStringRef pFullPath = CFStringCreateWithFormat(kCFAllocatorDefault,
                                                                         nullptr,
                                                                         pFormat,
                                                                         pPathname,
                                                                         pFileExt);
                        
                        if(pFullPath)
                        {
                            pURL = CFFileCreateURL(pFullPath);
                            
                            CFRelease(pFullPath);
                        } // if
                    } // if
                    else
                    {
                        pURL = CFFileCreateURL(pPathname);
                    } // else
                    
                    CFRelease(pPathname);
                } // if
                
                CFRelease(pComponents);
            } // if
        } // if
    } // if
    
    return pURL;
} // CFFileCreateURL

#pragma mark -
#pragma mark Private - Utilities - Writing

static bool CFFileWrite(CFURLRef pURL,
                        CFDataRef pData)
{
    bool bSuccess = (pURL != nullptr) && (pData != nullptr);
    
    if(bSuccess)
    {
        const CFIndex  nLength = CFDataGetLength(pData);
        const UInt8*   pBuffer = CFDataGetBytePtr(pData);
        
        bSuccess = (nLength > 0) && (pBuffer != nullptr);
        
        if(bSuccess)
        {
            CFWriteStreamRef pStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, pURL);
            
            if(pStream != nullptr)
            {
                bSuccess = CFWriteStreamOpen(pStream);
                
                if(bSuccess)
                {
                    CFIndex nSize = CFWriteStreamWrite(pStream, pBuffer, nLength);
                    
                    bSuccess = nLength == nSize;
                    
                    CFWriteStreamClose(pStream);
                } // if
                
                CFRelease(pStream);
            } // if
        } // if
    } // if
    
    return bSuccess;
} // CFFileWrite

#pragma mark -
#pragma mark Private - Utilities - Strings

static bool CFFileStringHasPropertyListExt(CFStringRef pPathname)
{
    CFRange              foundRange;
    CFRange              searchRange   = CFRangeMake(0, CFStringGetLength(pPathname));
    CFStringRef          searchStr     = CFSTR("plist");
    CFStringCompareFlags searchOptions = kCFCompareCaseInsensitive;
    
    return CFStringFindWithOptions(pPathname, searchStr, searchRange, searchOptions, &foundRange);
} // CFFileStringHasPropertyListExt

static bool CFFileStringIsPropertyListExt(CFStringRef pExt)
{
    CFRange              searchRange   = CFRangeMake(0, CFStringGetLength(pExt));
    CFStringRef          searchStr     = CFSTR("plist");
    CFStringCompareFlags searchOptions = kCFCompareCaseInsensitive;
    
    CFComparisonResult result = CFStringCompareWithOptions(pExt, searchStr, searchRange, searchOptions);
    
    return result == kCFCompareEqualTo;
} // CFFileStringIsPropertyListExt

static bool CFFileStringHasPropertyListExt(CFStringRef pName, CFStringRef pExt)
{
    return (pExt != nullptr) ? CFFileStringIsPropertyListExt(pExt) : CFFileStringHasPropertyListExt(pName);
} // CFFileStringHasPropertyListExt

#pragma mark -
#pragma mark Private - Methods

// Initialize all instance variables
void File::initialize()
{
    mnFormat    = kCFPropertyListXMLFormat_v1_0;
    mnOptions   = kCFPropertyListMutableContainers;
    mnDirectory = CFSearchPathDirectory(0);
    mnDomain    = NSAllDomainsMask;
    mnLength    = 0;
    mpPList     = nullptr;
    mpError     = nullptr;
    mpData      = nullptr;
    mpURL       = nullptr;
} // initialize

// Create and initialize all ivars
void File::acquire(const bool& isPList)
{
    mpData  = CFFileCreate(mpURL);
    
    if(mpData != nullptr)
    {
        mnLength = CFDataGetLength(mpData);
        
        if(isPList)
        {
            CFErrorRef pError = nullptr;
            
            mpPList = CFPropertyListCreateWithData(kCFAllocatorDefault,
                                                   mpData,
                                                   mnOptions,
                                                   &mnFormat,
                                                   &pError);
            
            if(pError != nullptr)
            {
                mpError = CFErrorCopyDescription(pError);
                
                CFRelease(pError);
            } // if
        } // if
    } // if
} // acquire

// Create a deep-copy
void File::clone(const File& rFile)
{
    mnOptions = rFile.mnOptions;
    mnFormat  = rFile.mnFormat;
    
    if(rFile.mpData != nullptr)
    {
        CFDataRef pData = CFDataCreateCopy(kCFAllocatorDefault, rFile.mpData);
        
        if(pData != nullptr)
        {
            if(mpData != nullptr)
            {
                CFRelease(mpData);
            } // if
            
            mpData = pData;
        } // if
    } // if
    
    if(rFile.mpPList != nullptr)
    {
        CFPropertyListRef pPList = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, rFile.mpPList, mnOptions);
        
        if(pPList != nullptr)
        {
            if(mpPList != nullptr)
            {
                CFRelease(mpPList);
            } // if
            
            mpPList = pPList;
        } // if
    } // if
    
    if(rFile.mpError != nullptr)
    {
        CFStringRef pError = CFStringCreateCopy(kCFAllocatorDefault, rFile.mpError);
        
        if(pError != nullptr)
        {
            if(mpError != nullptr)
            {
                CFRelease(mpError);
            } // if
            
            mpError = pError;
        } // if
    } // if
    
    if(rFile.mpURL != nullptr)
    {
        CFURLRef pURL = CFURLCreateWithString(kCFAllocatorDefault,
                                              CFURLGetString(rFile.mpURL),
                                              CFURLGetBaseURL(rFile.mpURL));
        
        if(pURL != nullptr)
        {
            if(mpURL != nullptr)
            {
                CFRelease(mpURL);
            } // if
            
            mpURL = pURL;
        } // if
    } // if
} // clone

// Create a deep-copy of the property list
void File::clone(CFPropertyListRef pPListSrc)
{
    CFPropertyListRef pPListDst = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, pPListSrc, mnOptions);
    
    if(pPListDst != nullptr)
    {
        if(mpPList != nullptr)
        {
            CFRelease(mpPList);
        } // if
        
        mpPList = pPListDst;
        
        CFErrorRef pError = nullptr;
        
        CFDataRef pData = CFPropertyListCreateData(kCFAllocatorDefault, mpPList, mnFormat, mnOptions, &pError);
        
        if(pError != nullptr)
        {
            CFStringRef pDescription = CFErrorCopyDescription(pError);
            
            if(pDescription != nullptr)
            {
                if(mpError != nullptr)
                {
                    CFRelease(mpError);
                } // if
                
                mpError = pDescription;
            } // if
            
            CFRelease(pError);
        } // if
        
        if(pData != nullptr)
        {
            if(mpData != nullptr)
            {
                CFRelease(mpData);
            } // if
            
            mpData   = pData;
            mnLength = CFDataGetLength(mpData);
        } // else
    } // if
} // clone

// Write the file to a location using url
bool File::write(CFURLRef pURL)
{
    bool bSuccess = false;
    
    if(mpURL != nullptr)
    {
        CFRelease(mpURL);
    } // if
    
    mpURL = pURL;
    
    bSuccess = CFFileWrite(mpURL, mpData);
    
    return bSuccess;
} // write

#pragma mark -
#pragma mark Public - Constructors

// Constructor for reading a file with an absolute pathname
File::File(CFStringRef pPathname)
{
    initialize();
    
    mpURL = CFFileCreateURL(pPathname);
    
    if(mpURL != nullptr)
    {
        bool isPList = CFFileStringHasPropertyListExt(pPathname);
        
        acquire(isPList);
    } // if
} // Constructor

// Constructor for reading a file in an application's bundle
File::File(CFStringRef pFileName,
           CFStringRef pFileExt)
{
    initialize();
    
    mpURL = CFFileCreateURL(pFileName, pFileExt);
    
    if(mpURL != nullptr)
    {
        bool isPList = CFFileStringHasPropertyListExt(pFileName, pFileExt);
        
        acquire(isPList);
    } // if
} // Constructor

// Constructor for reading a file in a domain
File::File(const CFSearchPathDomainMask& domain,
           const CFSearchPathDirectory& directory,
           CFStringRef pDirName,
           CFStringRef pFileName,
           CFStringRef pFileExt)
{
    initialize();
    
    mpURL = CFFileCreateURL(domain, directory, pDirName, pFileName, pFileExt);
    
    if(mpURL != nullptr)
    {
        mnDirectory = directory;
        mnDomain    = domain;
        
        bool isPList = CFFileStringHasPropertyListExt(pFileName, pFileExt);
        
        acquire(isPList);
    } // if
} // Constructor

// Constructor for reading a file using a URL
File::File(CFURLRef pURL)
{
    initialize();
    
    if(pURL != nullptr)
    {
        mpURL = CFURLCreateWithString(kCFAllocatorDefault,
                                      CFURLGetString(pURL),
                                      CFURLGetBaseURL(pURL));
        
        if(mpURL != nullptr)
        {
            bool isPList = CFFileStringHasPropertyListExt(CFURLGetString(mpURL));
            
            acquire(isPList);
        } // if
    } // if
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

// Delete the object
File::~File()
{
    if(mpData != nullptr)
    {
        CFRelease(mpData);
        
        mpData = nullptr;
    } // if
    
    if(mpPList != nullptr)
    {
        CFRelease(mpPList);
        
        mpPList = nullptr;
    } // if
    
    if(mpError != nullptr)
    {
        CFRelease(mpError);
        
        mpError = nullptr;
    } // if
    
    if(mpURL != nullptr)
    {
        CFRelease(mpURL);
        
        mpURL = nullptr;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Copy Constructor

// Copy constructor for deep-copy
File::File(const File& rFile)
{
    clone(rFile);
} // Copy Constructor

#pragma mark -
#pragma mark Public - Assignment Operators

// Assignment operator for deep object copy
File& File::operator=(const File& rFile)
{
    if(this != &rFile)
    {
        clone(rFile);
    } // if
    
    return *this;
} // Operator =

// Assignment operator for propert list deep-copy
File& File::operator=(CFPropertyListRef pPListSrc)
{
    if(pPListSrc != nullptr)
    {
        clone(pPListSrc);
    } // if
    
    return *this;
} // Operator =

#pragma mark -
#pragma mark Public - Accessors

// Accessor to return a c-string representation of the read file
const char* File::cstring() const
{
    return (mpData != nullptr) ? reinterpret_cast<const char*>(CFDataGetBytePtr(mpData)) : nullptr;
} // cstring

// Accessor, if the read file was a data file
const uint8_t* File::bytes() const
{
    return (mpData != nullptr) ? CFDataGetBytePtr(mpData) : nullptr;
} // bytes

// Length of the data or the string
const CFIndex File::length() const
{
    return mnLength;
} // length

// Options used for reading the property list
const CFOptionFlags File::options() const
{
    return mnOptions;
} // options

// Options used for reading the property list
const CFPropertyListFormat File::format() const
{
    return mnFormat;
} // format

// Domain mask for searching for a file
const CFSearchPathDomainMask File::domain() const
{
    return mnDomain;
} // domain

// Directory enumerated type for seaching for a file
const CFSearchPathDirectory File::directory() const
{
    return mnDirectory;
} // directory

// File's representation as data
CFDataRef File::data() const
{
    return mpData;
} // data

// Property list
CFPropertyListRef File::plist() const
{
    return mpPList;
} // plist

// Error associated with creating a property list
CFStringRef File::error() const
{
    return mpError;
} // error

// File's url
CFURLRef File::url() const
{
    return mpURL;
} // url

#pragma mark -
#pragma mark Public - Strings

// Create a text string from the contents of a file
std::string File::string()
{
    std::string string;
    
    const UInt8 *pBytes = CFDataGetBytePtr(mpData);
    
    if(pBytes != nullptr)
    {
        string = reinterpret_cast<const char*>(pBytes);
    } // if
    
    return string;
} // string

// Create a cf string from the contents of a file
CFStringRef File::cfstring()
{
    CFStringRef string = nullptr;
    
    const UInt8 *pBytes = CFDataGetBytePtr(mpData);
    
    if(pBytes != nullptr)
    {
        CFIndex numBytes = CFDataGetLength(mpData);
        
        string = CFStringCreateWithBytes(kCFAllocatorDefault, pBytes, numBytes, kCFStringEncodingUTF8, true);
    } // if
    
    return string;
} // cfstring

#pragma mark -
#pragma mark Public - Query

// Query for if the file was a property list
const bool File::isPList() const
{
    return (mpPList != nullptr) ? bool(CFPropertyListIsValid(mpPList, mnFormat)) : false;
} // isPList

#pragma mark -
#pragma mark Public - Write

// Write to the original location
bool File::write()
{
    return CFFileWrite(mpURL, mpData);
} // write

// Write the file to a location using an absolute pathname
bool File::write(CFStringRef pPathname)
{
    CFURLRef pURL = CFFileCreateURL(pPathname);
    
    bool bSuccess = pURL != nullptr;
    
    if(bSuccess)
    {
        bSuccess = write(pURL);
    } // if
    
    return bSuccess;
} // write

// Write the file to the application's bundle
bool File::write(CFStringRef pName, CFStringRef pExt)
{
    CFURLRef pURL = CFFileCreateURL(pName, pExt);
    
    bool bSuccess = pURL != nullptr;
    
    if(bSuccess)
    {
        bSuccess = write(pURL);
    } // if
    
    return bSuccess;
} // write
