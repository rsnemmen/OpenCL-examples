/*
 <codex>
 <import>NBodySimulationBase.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cstdlib>

#import <libkern/OSAtomic.h>

#import "CFQueryHardware.h"

#import "NBodySimulationBase.h"

#pragma mark -
#pragma mark Private - Namespaces

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Constants

static const std::string kOptions = "-cl-fast-relaxed-math -cl-mad-enable";

static const GLdouble kScaleYear = 1.8e7;

#pragma mark -
#pragma mark Public - Utilities

void *NBody::Simulation::simulate(void *arg)
{
    Base *pBase = (Base *)arg;
    
    pBase->run();
    
    pthread_exit((void *)pBase->mnMaxIndex);
} // simulate

Base::Base(const Properties& properties)
: m_Timer(20, false),
m_Updates(20, false)
{
    if(properties.mnParticles)
    {
        m_Options = kOptions;
        
        m_Properties = properties;
        
        mnCardinality = properties.mnParticles * properties.mnParticles;
        mnMaxIndex    = properties.mnParticles;
        mnLength      = 4 * properties.mnParticles;
        mnSamples     = sizeof(GLfloat);
        mnSize        = mnLength * mnSamples;
        
        mbAcquired  = false;
        mbIsUpdated = true;
        mbKeepAlive = true;
        mbStop      = false;
        mbReload    = false;
        mbPaused    = false;
        
        mpData   = nullptr;
        m_Thread = nullptr;
        
        m_DeviceName[0] = '\0';
        
        mnMinIndex    = 0;
        mnDeviceCount = 0;
        mnDevices     = 0;
        
        mnTime    = 0.0f;
        mnUpdates = 0.0f;
        
        CF::Query::Hardware hw;
        
        // This number is used to measure relative performance.
        // The baseline is that of multi-core CPU performance
        // and all performance numbers are measured relative
        // to this number. And as such this is not the traditional
        // giga (or tera) flops performance numbers.
        mnDelta = GLdouble(mnCardinality) * hw.scale();
        
        pthread_mutexattr_init(&m_ClockAttrib);
        pthread_mutexattr_settype(&m_ClockAttrib, PTHREAD_MUTEX_RECURSIVE);
        
        pthread_mutex_init(&m_ClockLock, &m_ClockAttrib);
        
        pthread_mutexattr_init(&m_RunAttrib);
        pthread_mutexattr_settype(&m_RunAttrib, PTHREAD_MUTEX_RECURSIVE);
        
        pthread_mutex_init(&m_RunLock, &m_RunAttrib);
    } // if
} // Base

Base::~Base()
{
    pthread_mutex_destroy(&m_ClockLock);
    pthread_mutexattr_destroy(&m_ClockAttrib);
    
    pthread_mutex_destroy(&m_RunLock);
    pthread_mutexattr_destroy(&m_RunAttrib);
    
    if(!m_Options.empty())
    {
        m_Options.clear();
    } // if
    
    GLfloat *pData = data();
    
    if(pData != nullptr)
    {
        std::free(pData);
        
        pData = nullptr;
    } // if
} // Destructor

const bool Base::isAcquired() const
{
    return mbAcquired;
} // isAcquired

const bool Base::isPaused() const
{
    return mbPaused;
} // isPaused

const bool Base::isStopped() const
{
    return mbStop;
} // isStopped

void Base::start(const bool& paused)
{
    pause();
    
    pthread_create(&m_Thread, nullptr, simulate, this);
    
    if(!paused)
    {
        unpause();
    } // if
} // start

void Base::stop()
{
    pause();
    {
        mbStop = true;
    }
    unpause();
    
    pthread_join(m_Thread, nullptr);
    
    mbAcquired = false;
} // stop

void Base::pause()
{
    if(!mbPaused)
    {
        if(mbKeepAlive)
        {
            pthread_mutex_lock(&m_RunLock);
        } // if
        
        mbPaused = true;
    } // if
} // pause

void Base::unpause()
{
    if(mbPaused)
    {
        mbPaused = false;
        
        pthread_mutex_unlock(&m_RunLock);
    } // if
} // unpause

void Base::exit()
{
    mbKeepAlive = false;
} // exit

void Base::resetProperties(const Properties& Properties)
{
    pause();
    {
        mnMinIndex   = 0;
        mnMaxIndex   = Properties.mnParticles;
        m_Properties = Properties;
        
        m_Timer.erase();
        
        mnTime = 0;
        
        m_Updates.erase();
        
        mnUpdates = 0;
        mbReload  = true;
        mnYear    = 2.755e9;
    }
    unpause();
} // resetProperties

void Base::setProperties(const Properties& Properties)
{
    m_Properties = Properties;
    
    mbReload = true;
} // setProperties

void Base::setRange(const GLint& min,
                    const GLint& max)
{
    mnMinIndex = min;
    mnMaxIndex = max;
} // setRange

void Base::invalidate(const bool& v)
{
    mbIsUpdated = v;
} // invalidate

void Base::setData(const GLfloat * const pData)
{
    if(pData != nullptr)
    {
        GLfloat *pDataDst = (GLfloat *)std::calloc(mnLength, mnSamples);
        
        if(pDataDst != nullptr)
        {
            std::memcpy(pDataDst, pData, mnSize);
            
            void *pDataSrc = nullptr;
            
            do
            {
                pDataSrc = mpData;
            }
            while(!OSAtomicCompareAndSwapPtrBarrier(pDataSrc, pDataDst, &mpData));
            
            std::free(pDataSrc);
            
            pDataSrc = nullptr;
        }// if
    } // if
} // setData

GLfloat *Base::data()
{
    void *pDataSrc = nullptr;
    
    do
    {
        pDataSrc = mpData;
    }
    while(!OSAtomicCompareAndSwapPtrBarrier(pDataSrc, nullptr, &mpData));
    
    return (GLfloat *)pDataSrc;
} // data

void Base::run()
{
    pthread_mutex_lock(&m_ClockLock);
    {
        initialize(m_Options);
    }
    pthread_mutex_unlock(&m_ClockLock);
    
    while(mbKeepAlive)
    {
        pthread_mutex_lock(&m_RunLock);
        {
            if(mbStop)
            {
                pthread_mutex_unlock(&m_ClockLock);
                pthread_mutex_unlock(&m_RunLock);
                
                return;
            } // if
            
            if (mbReload)
            {
                pthread_mutex_lock(&m_ClockLock);
                {
                    reset();
                }
                pthread_mutex_unlock(&m_ClockLock);
                
                mbReload = false;
            } // if
            
            pthread_mutex_lock(&m_ClockLock);
            {
                m_Timer.start();
                {
                    step();
                }
                m_Timer.stop();
            }
            pthread_mutex_unlock(&m_ClockLock);
        }
        pthread_mutex_unlock(&m_RunLock);
        
        m_Timer.update(mnDelta);
        
        mnTime = m_Timer.persecond();
        
        m_Updates.setStart(m_Timer.getStart());
        m_Updates.setStop(m_Timer.getStop());
        m_Updates.update();
        
        mnUpdates = std::ceil(m_Updates.persecond());
        
        // normalize for NBody::Scale::kTime at 0.4
        mnYear += kScaleYear * m_Properties.mnTimeStep;
    } // while
    
    pthread_mutex_lock(&m_ClockLock);
    {
        terminate();
    }
    pthread_mutex_unlock(&m_ClockLock);
} // run

const GLdouble& Base::performance() const
{
    return mnTime;
} // performance

const GLdouble& Base::updates() const
{
    return mnUpdates;
} // updates

const GLdouble& Base::year() const
{
    return mnYear;
} // year

const size_t& Base::size() const
{
    return mnSize;
} // size

const std::string& Base::name() const
{
    return m_DeviceName;
} // name

const size_t& Base::minimum() const
{
    return mnMinIndex;
} // minimum

const size_t& Base::maximum() const
{
    return mnMaxIndex;
} // maximum

const GLuint& Base::devices() const
{
    return mnDevices;
} // devices

