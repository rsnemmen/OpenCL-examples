/*
 <codex>
 <import>NBodySimulationDataGalaxy.h</import>
 </codex>
 */

#import "NBodySimulationDataGalaxy.h"

using namespace NBody::Simulation::Data;

static CFStringRef kGalaxyDataFileExt = CFSTR("dat");

static CFStringRef kGalaxyDataFileName[5] =
{
    CFSTR("particles_16k"),
    CFSTR("particles_24k"),
    CFSTR("particles_32k"),
    CFSTR("particles_64k"),
    CFSTR("particles_80k")
};

CF::DataFile* Galaxy::create(const size_t& nParticles)
{
    CFStringRef pFileName = nullptr;
    
    switch(nParticles)
    {
        case 24576:
            pFileName = kGalaxyDataFileName[1];
            break;
            
        case 32768:
            pFileName = kGalaxyDataFileName[2];
            break;
            
        case 65536:
            pFileName = kGalaxyDataFileName[3];
            break;
            
        case 81920:
            pFileName = kGalaxyDataFileName[4];
            break;
            
        case 16384:
        default:
            pFileName = kGalaxyDataFileName[0];
            break;
    } // switch
    
    return new (std::nothrow) CF::DataFile(pFileName, kGalaxyDataFileExt);
} // create

// Acquire the galaxy file using properties
Galaxy::Galaxy(const size_t nParticles)
{
    mnParticles = nParticles;
    mpData   = create(mnParticles);
} // Constructor

// Copy constructor for deep-copy
Galaxy::Galaxy(const Galaxy& rGalaxy)
{
    mnParticles = rGalaxy.mnParticles;
    mpData   = new (std::nothrow) CF::DataFile(*rGalaxy.mpData);
} // Copy Constructor

// Delete the object
Galaxy::~Galaxy()
{
    if(mpData != nullptr)
    {
        delete mpData;
        
        mpData = nullptr;
    } // if
    
    mnParticles = 0;
} // Destructor

// Assignment operator for deep object copy
Galaxy& Galaxy::operator=(const Galaxy& rGalaxy)
{
    if(this != &rGalaxy)
    {
        mnParticles = rGalaxy.mnParticles;
        
        CF::DataFile* pData = new (std::nothrow) CF::DataFile(*rGalaxy.mpData);
        
        if(pData != nullptr)
        {
            if(mpData != nullptr)
            {
                delete mpData;
            } // if
            
            mpData = pData;
        } // if
    } // if
    
    return *this;
} // Assignment Operator

// End-of-File
const bool Galaxy::eof() const
{
    return mpData->eof();
} // eof

// Row count
const size_t Galaxy::rows() const
{
    return mpData->rows();
} // rows

// Column count
const size_t Galaxy::columns() const
{
    return mpData->columns();
} // columns

// File length, or the number of bytes
const size_t Galaxy::length() const
{
    return mpData->length();
} // length

// Current line
const size_t Galaxy::line() const
{
    return mpData->line();
} // line

// Reset the file content pointer to the beginning, past the header
void Galaxy::reset()
{
    mpData->reset();
} // reset

// Float vector from a line in the data file
std::vector<float> Galaxy::floats()
{
    return mpData->floats();
} // floats

// Double vector from a line in the data file
std::vector<double> Galaxy::doubles()
{
    return mpData->doubles();
} // doubles

