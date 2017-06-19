/*
 <codex>
 <import>CFHostInfo.h</import>
 </codex>
 */

#import "CFProcessorInfoArray.h"
#import "CFCPUHostInfo.h"

using namespace CF::CPU;

static const size_t kSizeInteger = sizeof(natural_t);

static natural_t CFCPUHostInfoGetState(const uint32_t& i,
                                       const natural_t& nCount,
                                       const natural_t& type,
                                       processor_info_array_t pInfo)
{
    natural_t nState = 0;
    
    if(pInfo != nullptr)
    {
        nState = (i < nCount) ? pInfo[CPU_STATE_MAX * i + type] : 0;
    } // if
    
    return nState;
} // CFCPUHostInfoGetState

static natural_t CFCPUHostInfoGetUserState(const uint32_t& i,
                                           const natural_t& nCount,
                                           processor_info_array_t pInfo)
{
    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_USER, pInfo);
} // CFCPUHostInfoGetUserState

static natural_t CFCPUHostInfoGetSystemState(const uint32_t& i,
                                             const natural_t& nCount,
                                             processor_info_array_t pInfo)
{
    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_SYSTEM, pInfo);
} // CFCPUHostInfoGetSystemState

static natural_t CFCPUHostInfoGetIdleState(const uint32_t& i,
                                           const natural_t& nCount,
                                           processor_info_array_t pInfo)
{
    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_IDLE, pInfo);
} // CFCPUHostInfoGetIdleState

static natural_t CFCPUHostInfoGetNiceState(const uint32_t& i,
                                           const natural_t& nCount,
                                           processor_info_array_t pInfo)
{
    return CFCPUHostInfoGetState(i, nCount, CPU_STATE_NICE, pInfo);
} // CFCPUHostInfoGetNiceState

static size_t CFCPUHostInfoGetSum(const uint32_t& i,
                                  const natural_t& nCount,
                                  processor_info_array_t pInfo)
{
    natural_t nSum = 0;
    
    if((i < nCount) && (pInfo != nullptr))
    {
        natural_t nOffset = CPU_STATE_MAX * i;
        natural_t nUser   = pInfo[nOffset + CPU_STATE_USER];
        natural_t nSytem  = pInfo[nOffset + CPU_STATE_SYSTEM];
        natural_t nIde    = pInfo[nOffset + CPU_STATE_IDLE];
        natural_t nNice   = pInfo[nOffset + CPU_STATE_NICE];
        
        nSum = nSytem + nIde + nNice + nUser;
    } // if
    
    return nSum;
} // CFCPUHostInfoGetSum

HostInfo::HostInfo()
{
    mnCount  = 0;
    mnInfo   = 0;
    mpInfo   = nullptr;
    mnFlavor = PROCESSOR_CPU_LOAD_INFO;
    mnError  = host_processor_info(mach_host_self(), mnFlavor, &mnCount, &mpInfo, &mnInfo);
    mnSize   = kSizeInteger * mnInfo;
} // Constructor

HostInfo::HostInfo(const HostInfo& rHostInfo)
{
    mnCount  = rHostInfo.mnCount;
    mnInfo   = rHostInfo.mnInfo;
    mnSize   = kSizeInteger * rHostInfo.mnInfo;
    mnFlavor = PROCESSOR_CPU_LOAD_INFO;
    mpInfo   = ProcessorInfoArrayCreateCopy(mnSize, rHostInfo.mpInfo, mnError);
} // Copy Constructor

HostInfo::~HostInfo()
{
    ProcessorInfoArrayDelete(mnSize, mpInfo);
    
    mnCount  = 0;
    mnInfo   = 0;
    mnSize   = 0;
    mnFlavor = 0;
    mnError  = 0;
} // Destructor

HostInfo& HostInfo::operator=(const HostInfo& rHostInfo)
{
    if(this != &rHostInfo)
    {
        if((mnInfo != rHostInfo.mnInfo) || (mpInfo == nullptr))
        {
            processor_info_array_t pInfo = ProcessorInfoArrayCreateCopy(rHostInfo.mnSize,
                                                                        rHostInfo.mpInfo,
                                                                        mnError);
            
            if(mnError == KERN_SUCCESS)
            {
                mnError = ProcessorInfoArrayDelete(mnSize, mpInfo);
                
                if(mnError == KERN_SUCCESS)
                {
                    mpInfo = pInfo;
                } // if
                else
                {
                    ProcessorInfoArrayDelete(mnSize, pInfo);
                } // else
            } // if
        } // if
        else
        {
            mnError = ProcessorInfoArrayCopy(rHostInfo.mnSize, rHostInfo.mpInfo, mpInfo);
        } // else
        
        if(mnError == KERN_SUCCESS)
        {
            mnSize   = rHostInfo.mnSize;
            mnCount  = rHostInfo.mnCount;
            mnInfo   = rHostInfo.mnInfo;
            mnFlavor = PROCESSOR_CPU_LOAD_INFO;
        } // if
    } // if
    
    return *this;
} // Assignment Operator

const kern_return_t HostInfo::error() const
{
    return mnError;
} // error

const processor_flavor_t HostInfo::flavor() const
{
    return mnFlavor;
} // flavor

const natural_t HostInfo::cpus() const
{
    return mnCount;
} // cpus

const natural_t HostInfo::size() const
{
    return mnSize;
} // size

const natural_t HostInfo::user(const uint32_t& i) const
{
    return CFCPUHostInfoGetUserState(i, mnCount, mpInfo);
} // user

const natural_t HostInfo::system(const uint32_t& i) const
{
    return CFCPUHostInfoGetSystemState(i, mnCount, mpInfo);
} // system

const natural_t HostInfo::idle(const uint32_t& i) const
{
    return CFCPUHostInfoGetIdleState(i, mnCount, mpInfo);
} // idle

const natural_t HostInfo::nice(const uint32_t& i) const
{
    return CFCPUHostInfoGetNiceState(i, mnCount, mpInfo);
} // nice

const size_t HostInfo::total(const uint32_t& i) const
{
    return CFCPUHostInfoGetSum(i, mnCount, mpInfo);
} // total


