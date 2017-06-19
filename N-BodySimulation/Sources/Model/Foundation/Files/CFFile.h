/*
 <codex>
 <abstract>
 Utility methods for managing input file streams.
 </abstract>
 </codex>
 */


#ifndef _CF_FILE_H_
#define _CF_FILE_H_

#import <iostream>
#import <string>

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus

typedef NSSearchPathDirectory  CFSearchPathDirectory;
typedef NSSearchPathDomainMask CFSearchPathDomainMask;

namespace CF
{
    class File
    {
    public:
        // Constructor for reading a file with an absolute pathname
        File(CFStringRef pPathname);
        
        // Constructor for reading a file in an application's bundle
        File(CFStringRef pName, CFStringRef pExt);
        
        // Constructor for reading a file in a domain
        File(const CFSearchPathDomainMask& domain,
             const CFSearchPathDirectory& directory,
             CFStringRef pDirName,
             CFStringRef pFileName,
             CFStringRef pFileExt);
        
        // Constructor for reading a file using a URL
        File(CFURLRef pURL);
        
        // Copy constructor for deep-copy
        File(const File& rFile);
        
        // Delete the object
        virtual ~File();
        
        // Assignment operator for deep object copy
        File& operator=(const File& rFile);
        
        // Assignment operator for property list deep-copy
        File& operator=(CFPropertyListRef pPListSrc);
        
        // Accessor to return a c-string representation of the read file
        const char* cstring() const;
        
        // Accessor, if the read file was a data file
        const uint8_t* bytes() const;
        
        // Length of the data or the string
        const CFIndex length() const;
        
        // Options used for reading the property list
        const CFOptionFlags options() const;
        
        // Format used for reading the property list
        const CFPropertyListFormat format() const;
        
        // Domain mask for searching for a file
        const CFSearchPathDomainMask domain() const;
        
        // Directory enumerated type for seaching for a file
        const CFSearchPathDirectory directory() const;
        
        // File's representation as data
        CFDataRef data() const;
        
        // Error associated with creating a property list
        CFStringRef error() const;
        
        // Property list
        CFPropertyListRef plist() const;
        
        // File's url
        CFURLRef url() const;
        
        // Query for if the file was a property list
        const bool isPList() const;
        
        // Create a text string from the contents of a file
        std::string string();
        
        // Create a cf string from the contents of a file
        CFStringRef cfstring();
        
        // Write to the original location
        bool write();
        
        // Write the file to a location using an absolute pathname
        bool write(CFStringRef pPathname);
        
        // Write the file to the application's bundle
        bool write(CFStringRef pName, CFStringRef pExt);
        
    private:
        // Initialize all instance variables
        void initialize();
        
        // Create and initialize all ivars
        void acquire(const bool& isPList);
        
        // Create a deep-copy
        void clone(const File& rFile);
        
        // Create a deep-copy of the property list
        void clone(CFPropertyListRef pPListSrc);
        
        // Write the file to a location using url
        bool write(CFURLRef pURL);
        
    private:
        CFIndex                 mnLength;
        CFURLRef                mpURL;
        CFDataRef               mpData;
        CFPropertyListRef       mpPList;
        CFPropertyListFormat    mnFormat;
        CFOptionFlags           mnOptions;
        CFStringRef             mpError;
        CFSearchPathDirectory   mnDirectory;
        CFSearchPathDomainMask  mnDomain;
    };
} // CF

#endif

#endif

