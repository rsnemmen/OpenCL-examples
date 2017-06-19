/*
 <codex>
 <import>HUDMeterTimer.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <mach/mach_time.h>
#import <unistd.h>

#import "HUDMeterTimer.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace HUD::Meter;

#pragma mark -
#pragma mark Private - Constants

namespace HUD
{
    namespace Meter
    {
        double_t TimeScale::kSeconds      = 1.0e-9;
        double_t TimeScale::kMilliSeconds = 1.0e-6;
        double_t TimeScale::kMicroSeconds = 1.0e-3;
        double_t TimeScale::kNanoSeconds  = 1.0f;
    } // Meter
} // HUD

#pragma mark -
#pragma mark Public - Meter - Timer

Timer::Timer(const size_t& size,
             const bool& doAscend,
             const GLdouble& scale)
{
    mach_timebase_info_data_t timebase;
    
    kern_return_t result = mach_timebase_info(&timebase);
    
    if(result == KERN_SUCCESS)
    {
        mnAspect = double_t(timebase.numer) / double_t(timebase.denom);
        mnScale  = scale;
        mnRes    = mnAspect * mnScale;
    } // if
    
    mnSize     = (size > 20) ? size : 20;
    mbAscend   = doAscend;
    mnIndex    = 0;
    mnCount    = 0;
    mnStart    = 0;
    mnStop     = 0;
    mnDuration = 0.0f;
    
    m_Vector.resize(mnSize);
    
    m_Vector = 0.0f;
} // Constructor

Timer::Timer(const Timer::Timer& timer)
{
    mnAspect   = timer.mnAspect;
    mnScale    = timer.mnScale;
    mnRes      = timer.mnRes;
    mnDuration = timer.mnDuration;
    m_Vector   = timer.m_Vector;
    mnSize     = timer.mnSize;
    mnStart    = timer.mnStart;
    mnStop     = timer.mnStop;
    mnCount    = timer.mnCount;
    mnIndex    = timer.mnIndex;
    mbAscend   = timer.mbAscend;
} // Copy Constructor

Timer::~Timer()
{
    mnAspect   = 0.0f;
    mnScale    = 0.0f;
    mnRes      = 0.0f;
    mnDuration = 0.0f;
    m_Vector   = 0.0f;
    mnSize     = 0;
    mnStart    = 0;
    mnStop     = 0;
    mnCount    = 0;
    mnIndex    = 0;
    mbAscend   = 0;
} // Destructor

Timer& Timer::operator=(const Timer& timer)
{
    if(this != &timer)
    {
        mnAspect   = timer.mnAspect;
        mnScale    = timer.mnScale;
        mnRes      = timer.mnRes;
        mnDuration = timer.mnDuration;
        m_Vector   = timer.m_Vector;
        mnSize     = timer.mnSize;
        mnStart    = timer.mnStart;
        mnStop     = timer.mnStop;
        mnCount    = timer.mnCount;
        mnIndex    = timer.mnIndex;
        mbAscend   = timer.mbAscend;
    } // if
    
    return *this;
} // Assignment Operator

bool Timer::resize(const size_t& size)
{
    bool bSuccess = (size != mnSize) && (size > 20);
    
    if(bSuccess)
    {
        mnSize = size;
        
        m_Vector.resize(mnSize);
    } // if
    
    return bSuccess;
} // resize

void Timer::setScale(const GLdouble& scale)
{
    if(scale > GLdouble(0))
    {
        mnScale = scale;
        mnRes   = mnAspect * mnScale;
    } // if
} // setScale

void Timer::setStart(const HUD::Meter::Time& time)
{
    mnStart = time;
} // setStart

void Timer::setStop(const HUD::Meter::Time& time)
{
    mnStop = time;
} // setStop

const HUD::Meter::Time& Timer::getStart() const
{
    return mnStart;
} // getStart

const HUD::Meter::Time& Timer::getStop()  const
{
    return mnStop;
} // getStop

const HUD::Meter::Duration& Timer::getDuration() const
{
    return mnDuration;
} // getDuration

void Timer::erase()
{
    m_Vector = 0.0f;
    mnCount  = 0;
} // erase

void Timer::update(const GLdouble& dx)
{
    GLdouble dt = mnRes * GLdouble(mnStop - mnStart);
    
    ++mnCount;
    
    m_Vector[mnIndex] = dx / dt;
    
    mnIndex = (mnIndex + 1) % mnSize;
} // update

const GLdouble Timer::persecond() const
{
    GLdouble nSize   = GLdouble(mnSize);
    GLdouble nMin    = GLdouble(std::min(mnCount, mnSize));
    GLdouble nMetric = mbAscend ? nSize : nMin;
    GLdouble nSum    = m_Vector.sum();
    
    return nSum / nMetric;
} // persecond

void Timer::start()
{
    mnStart = mach_absolute_time();
} // start

void Timer::stop()
{
    mnStop = mach_absolute_time();
} // stop

void Timer::reset()
{
    mnStart = mnStop;
} // reset

