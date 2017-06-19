/*
 <codex>
 <import>CFCPULoad.h</import>
 </codex>
 */

#import <iostream>

#import "CFCPUHostInfo.h"
#import "CFCPULoad.h"

using namespace CF::CPU;

Load::Load()
{
    mnTotalTime = 0;
    mnUserTime  = 0;
} // Constructor

Load::Load(const Load& rLoad)
{
    mnTotalTime = rLoad.mnTotalTime;
    mnUserTime  = rLoad.mnUserTime;
} // Copy Constructor

Load::~Load()
{
    mnTotalTime = 0;
    mnUserTime  = 0;
} // Constructor

Load& Load::operator=(const Load& rLoad)
{
    if(this != &rLoad)
    {
        mnTotalTime = rLoad.mnTotalTime;
        mnUserTime  = rLoad.mnUserTime;
    } // if
    
    return *this;
} // Assignment Operator

const size_t Load::total() const
{
    return mnTotalTime;
} // total

const size_t Load::user() const
{
    return mnUserTime;
} // user

double Load::percentage()
{
    double nResult = 0.0;
    
    HostInfo hostInfo;
    
    if(hostInfo.error() == KERN_SUCCESS)
    {
        size_t nTotalTime = 0;
        size_t nUserTime  = 0;
        
        natural_t nCPU;
        natural_t nCPUMax = hostInfo.cpus();
        
        for(nCPU = 0; nCPU < nCPUMax; ++nCPU)
        {
            nUserTime  += hostInfo.user(nCPU);
            nTotalTime += hostInfo.total(nCPU);
        } // for
        
        nResult = 100.0f * double(nUserTime  - mnUserTime) / double(nTotalTime - mnTotalTime);
        
        mnUserTime  = nUserTime;
        mnTotalTime = nTotalTime;
    } // if
    
    return nResult;
} // percentage
