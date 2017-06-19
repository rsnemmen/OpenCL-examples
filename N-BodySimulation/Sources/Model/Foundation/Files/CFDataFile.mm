/*
 <codex>
 <import>CFDataFile.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <algorithm>
#import <iterator>
#import <iostream>
#import <sstream>

#import "CFDataFile.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace CF;

#pragma mark -
#pragma mark Private - Utilities

// Initialize with a input data file
void DataFile::initialize(const char& nTerminator,
                          CF::File* pFile)
{
    mpBuffer = pFile->cstring();
    
    if(mpBuffer != nullptr)
    {
        mnTerminator = nTerminator;
        mnLength     = std::strlen(mpBuffer);
        mpBufferPos  = std::strchr(mpBuffer, mnTerminator);
        
        std::vector<size_t> vec = readline<size_t>();
        
        if(vec.size() > 1)
        {
            mnRows    = vec[0];
            mnColumns = vec[1];
        } // if
    } // if
} // initialize

// Make a deep-copy from an input data file object
void DataFile::clone(const DataFile& rDataFile)
{
    if(rDataFile.mpFile != nullptr)
    {
        CF::File* pFile = new (std::nothrow) CF::File(*rDataFile.mpFile);
        
        if(pFile != nullptr)
        {
            if(mpFile != nullptr)
            {
                delete mpFile;
            } // if
            
            mpFile = pFile;
            
            initialize(rDataFile.mnTerminator, mpFile);
        } // if
    } // kif
} // clone

// Clear the ivars
void DataFile::clear()
{
    mnRows       = 0;
    mnColumns    = 0;
    mnTerminator = 0;
    mnLine       = 0;
    mnLength     = 0;
    mpFile       = nullptr;
    mpBuffer     = nullptr;
    mpBufferPos  = nullptr;
} // clear

// Delete the file object and clear all other ivars
void DataFile::erase()
{
    if(mpFile != nullptr)
    {
        delete mpFile;
    } // if
    
    clear();
} // erase

// Create a new float or double vector from a string
template<typename T>
std::vector<T> DataFile::create(const std::string& rString)
{
    // Always prefer std::vector to std::valarray or std::array
    std::vector<T> vec;
    
    // Build an istream that holds the input string
    std::istringstream iss(rString);
    
    // Iterate over the istream, using >> to grab floats, or
    // doubles, and push_back to store them in the vector
    std::copy(std::istream_iterator<T>(iss),
              std::istream_iterator<T>(),
              std::back_inserter(vec));
    
    return vec;
} // create

// Read a single line of data from the file
template<typename T>
std::vector<T> DataFile::readline()
{
    std::string string;
    
    if(mpBufferPos != nullptr)
    {
        // Number of bytes to create a c-string
        size_t nBytes = mpBufferPos - mpBuffer;
        
        // Create c-string with a specified length (or number of bytes)
        string = std::string(mpBuffer, nBytes);
        
        // Advance the buffer to the beginning of the next line
        mpBuffer += nBytes + 1;
        
        // Advance the buffer position to the end of the next line
        mpBufferPos = std::strchr(mpBufferPos + 1, mnTerminator);
    } // if
    else
    {
        // The length of the last line of the input data file
        size_t nLength = (mpBuffer != nullptr) ? std::strlen(mpBuffer) : 0;
        
        if(nLength)
        {
            // Create a string with the specified length
            string = std::string(mpBuffer, nLength);
        } // if
    } // else
    
    // Advance the counter for the line count
    mnLine++;
    
    // Create a vector of floats or double from the string
    return create<T>(string);
} // readline

#pragma mark -
#pragma mark Public - Interfaces

// Constructor for reading from a data file with an absolute pathname
DataFile::DataFile(CFStringRef pPathname,
                   const char& nTerminator)
{
    clear();
    
    mpFile = new (std::nothrow) CF::File(pPathname);
    
    if(mpFile != nullptr)
    {
        initialize(nTerminator, mpFile);
    } // if
} // Constructor

// Constructor for reading from a data file in an application's bundle
DataFile::DataFile(CFStringRef pName,
                   CFStringRef pExt,
                   const char& nTerminator)
{
    clear();
    
    mpFile = new (std::nothrow) CF::File(pName, pExt);
    
    if(mpFile != nullptr)
    {
        initialize(nTerminator, mpFile);
    } // if
} // Constructor

// Constructor for reading from a data file in a domain
DataFile::DataFile(const CFSearchPathDomainMask& domain,
                   const CFSearchPathDirectory& directory,
                   CFStringRef pDirName,
                   CFStringRef pFileName,
                   CFStringRef pFileExt,
                   const char& nTerminator)
{
    clear();
    
    mpFile = new (std::nothrow) CF::File(domain, directory, pDirName, pFileName, pFileExt);
    
    if(mpFile != nullptr)
    {
        initialize(nTerminator, mpFile);
    } // if
} // Constructor

// Copy constructor
DataFile::DataFile(const DataFile& rDataFile)
{
    clone(rDataFile);
} // Copy constructor

// Assignment operator for deep object copy
DataFile& DataFile::operator=(const DataFile& rDataFile)
{
    if(this != &rDataFile)
    {
        clone(rDataFile);
    } // if
    
    return *this;
} // Assignment Operator

// Destructor
DataFile::~DataFile()
{
    DataFile::erase();
} // Destructor

// End-of-File
const bool DataFile::eof() const
{
    return mnLine > mnRows;
} // eof

// Row count
const size_t DataFile::rows() const
{
    return mnRows;
} // rows

// Column count
const size_t DataFile::columns() const
{
    return mnColumns;
} // columns

// File length, or the number of bytes
const size_t DataFile::length() const
{
    return mnLength;
} // length

// Current line
const size_t DataFile::line() const
{
    return mnLine;
} // line

// Reset the file content pointer to the beginning, past the header
void DataFile::reset()
{
    // Reset to the beginning of the file
    mpBuffer = mpFile->cstring();
    
    if(mpBuffer != nullptr)
    {
        char* pBufferPos = std::strchr(mpBuffer, mnTerminator);
        
        if(pBufferPos != nullptr)
        {
            // Skip the data file header line
            mnLine       = 1;
            mpBuffer    += (pBufferPos - mpBuffer + 1);
            mpBufferPos  = std::strchr(pBufferPos + 1, mnTerminator);
        } // if
    } // if
} // reset

// Float vector from a line in the data file
std::vector<float> DataFile::floats()
{
    return DataFile::readline<float>();
} // floats

// Double vector from a line in the data file
std::vector<double> DataFile::doubles()
{
    return DataFile::readline<double>();
} // doubles
