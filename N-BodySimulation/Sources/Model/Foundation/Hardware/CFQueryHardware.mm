/*
 <codex>
 <import>HUDMeter.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cstdio>
#import <cstdlib>

#import <sys/types.h>
#import <sys/sysctl.h>

#import "CFQueryHardware.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace CF::Query;

#pragma mark -
#pragma mark Public - Constants

double_t CF::Query::Frequency::kGigaHetrz = 1.0e-9;
double_t CF::Query::Frequency::kMegaHertz = 1.0e-6;
double_t CF::Query::Frequency::kKiloHertz = 1.0e-3;
double_t CF::Query::Frequency::kHertz     = 1.0f;

#pragma mark -
#pragma mark Private - Constants

static const size_t kGigaBytes = 1073741824;

#pragma mark -
#pragma mark Private - Utilities

static int CFQueryHardwareGetMemSize(size_t& gigabytes)
{
    size_t size  = sizeof(size_t);
    size_t bytes = sizeof(size_t);
    
    int result = sysctlbyname("hw.memsize", &bytes, &size, nullptr, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed for memory size!");
    } // if
    else
    {
        gigabytes = bytes / kGigaBytes;
    } // else
    
    return result;
} // CFQueryHardwareGetMemSize

static int CFQueryHardwareGetCPUCount(size_t& count)
{
    size_t size = sizeof(size_t);
    
    int result = sysctlbyname("hw.physicalcpu_max", &count, &size, nullptr, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed for max physical cpu count!");
    } // if
    
    return result;
} // CFQueryHardwareGetCPUCount

static int CFQueryHardwareGetCPUClock(double_t& clock)
{
    size_t freq = 0;
    size_t size = sizeof(size_t);
    
    int result = sysctlbyname("hw.cpufrequency_max", &freq, &size, nullptr, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed for max cpu frequency!");
    } // if
    else
    {
        clock = double_t(freq);
    } // else
    
    return result;
} // CFQueryHardwareGetCPUClock

static int CFQueryHardwareGetModel(std::string& model)
{
    size_t nLength = 0;
    
    int result = sysctlbyname("hw.model", nullptr, &nLength, nullptr, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed in acquring string length for the hardware model!");
        
        return result;
    } // if
    
    if(nLength)
    {
        char* pModel = new (std::nothrow) char[nLength];
        
        if(pModel != nullptr)
        {
            int result = sysctlbyname("hw.model", pModel, &nLength, nullptr, 0);
            
            if(result < 0)
            {
                std::perror("sysctlbyname() failed in acquring a hardware model name!");
            } // if
            else
            {
                model = pModel;
            } // else
            
            delete [] pModel;
        } // if
        else
        {
            std::perror("sysctlbyname() failed in acquring a string buffer for the hardware model!");
            
            result = -1;
        } // else
    } // if
    
    return result;
} // CFQueryHardwareGetModel

#pragma mark -
#pragma mark Public - Hardware

Hardware::Hardware(const double_t& frequency)
{
    mnCores = 0;
    mnCPU = 0.0f;
    mnFreq  = (frequency > 0.0f) ? frequency : CF::Query::Frequency::kGigaHetrz;
    mnScale = mnFreq;
    
    int result = CFQueryHardwareGetCPUCount(mnCores);
    
    if(result > -1)
    {
        result = CFQueryHardwareGetCPUClock(mnCPU);
        
        if(result > -1)
        {
            mnScale *= mnFreq * mnCPU * double_t(mnCores);
        } // if
    } // if
    
    CFQueryHardwareGetMemSize(mnSize);
    CFQueryHardwareGetModel(m_Model);
} // Constructor

Hardware::~Hardware()
{
    mnCores = 0;
    mnSize  = 0;
    mnFreq  = 0.0f;
    mnCPU   = 0.0f;
    mnScale = 0.0f;
    
    m_Model.clear();
} // Destructor

Hardware::Hardware(const Hardware& hw)
{
    mnCores = hw.mnCores;
    mnSize  = hw.mnSize;
    mnCPU   = hw.mnCPU;
    mnFreq  = hw.mnFreq;
    mnScale = hw.mnScale;
    m_Model = hw.m_Model;
} // Copy Constructor

Hardware& Hardware::operator=(const Hardware& hw)
{
    if(this != &hw)
    {
        mnCores = hw.mnCores;
        mnSize  = hw.mnSize;
        mnCPU   = hw.mnCPU;
        mnFreq  = hw.mnFreq;
        mnScale = hw.mnScale;
        m_Model = hw.m_Model;
    } // if
    
    return *this;
} // operator=

void Hardware::setFrequency(const double_t& frequency)
{
    mnFreq   = (frequency > 0.0f) ? frequency : CF::Query::Frequency::kGigaHetrz;
    mnScale  = mnFreq;
    mnScale *= mnFreq * mnCPU * double_t(mnCores);
} // setFrequency

const size_t& Hardware::cores() const
{
    return mnCores;
} // cores

const double_t& Hardware::cpu() const
{
    return mnCPU;
} // cpu

const size_t& Hardware::memory() const
{
    return mnSize;
} // memory

const double_t& Hardware::scale() const
{
    return mnScale;
} // scale

const std::string& Hardware::model() const
{
    return m_Model;
} // model
