/*
 <codex>
 <abstract>
 Utility methods for reading data from a text file.  The file's header contains the number of rows & columns.
 </abstract>
 </codex>
 */

#ifndef _CF_DATA_FILE_H_
#define _CF_DATA_FILE_H_

#import <vector>

#import "CFFile.h"

#ifdef __cplusplus

namespace CF
{
    class DataFile
    {
    public:
        // Constructor for reading from a data file with an absolute pathname
        DataFile(CFStringRef pPathname,
                 const char& nTerminator = '\n');
        
        // Constructor for reading from a data file in an application's bundle
        DataFile(CFStringRef pName,
                 CFStringRef pExt,
                 const char& nTerminator = '\n');
        
        // Constructor for reading from a data file in a domain
        DataFile(const CFSearchPathDomainMask& domain,
                 const CFSearchPathDirectory& directory,
                 CFStringRef pDirName,
                 CFStringRef pFileName,
                 CFStringRef pFileExt,
                 const char& nTerminator = '\n');
        
        // Copy constructor for deep-copy
        DataFile(const DataFile& rDataFile);
        
        // Destructor
        virtual ~DataFile();
        
        // Assignment operator for deep object copy
        DataFile& operator=(const DataFile& rDataFile);
        
        // End-of-File
        const bool eof() const;
        
        // Row count
        const size_t rows() const;
        
        // Column count
        const size_t columns() const;
        
        // File length, or the number of bytes
        const size_t length()  const;
        
        // Current line
        const size_t line() const;

        // Float vector from a line in the data file
        std::vector<float> floats();
        
        // Double vector from a line in the data file
        std::vector<double> doubles();
        
        // Reset the file content pointer to the beginning, past the header
        void reset();
        
    private:
        // Initialize with a input data file
        void initialize(const char& nTerminator,
                        File* mpFile);
        
        // Make a deep-copy from an input data file object
        void clone(const DataFile& rDataFile);
        
        // Clear the ivars
        void clear();
        
        // Delete the file object and clear all other ivars
        void erase();
        
        // Create a new float or double vector from a string
        template<typename T>
        std::vector<T> create(const std::string& rString);
        
        // Read a single line of data from the file 
        template<typename T>
        std::vector<T> readline();
        
    private:
        size_t      mnLength;
        size_t      mnRows;
        size_t      mnColumns;
        size_t      mnLine;
        char        mnTerminator;
        char*       mpBufferPos;
        const char* mpBuffer;
        CF::File*   mpFile;
    }; // DataFile
} // CF

#endif

#endif

