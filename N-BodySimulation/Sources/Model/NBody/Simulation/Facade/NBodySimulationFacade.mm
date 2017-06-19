/*
 <codex>
 <import>NBodySimulationFacade.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cstdio>

#import <sys/types.h>
#import <sys/sysctl.h>

#import "CFQueryHardware.h"

#import "NBodySimulationCPU.h"
#import "NBodySimulationGPU.h"
#import "NBodySimulationFacade.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Accessors

// Acquire a label for the gpu bound simulator
void Facade::setLabel(const GLint& nDevIndex,
                      const GLuint& nDevices,
                      const std::string& rDevice)
{
    CF::Query::Hardware hw;
    
    std::string model = hw.model();
    std::size_t found = model.find("MacPro");
    std::string label = nDevIndex ? "Secondary" : "Primary";
    
    bool isMacPro  = found != std::string::npos;
    bool isDualGPU = nDevices == 2;
    
    if(isMacPro && isDualGPU && nDevIndex)
    {
        label = "Primary + " + label;
    } // if
    
    m_Label = "SIM: " + label + " " + rDevice;
} // setLabel

#pragma mark -
#pragma mark Private - Constructors

Base *Facade::create(const GLint& nDevIndex,
                     const Properties& rProperties)
{
    Base *pSimulator = new (std::nothrow) GPU(rProperties, nDevIndex);
    
    if(pSimulator != nullptr)
    {
        size_t spin = 0;
        
        pSimulator->start();
        
        while(!pSimulator->isAcquired())
        {
            spin++;
        } // while
        
        mbIsGPU = true;
        
        setLabel(nDevIndex,
                 pSimulator->devices(),
                 pSimulator->name());
    } // if
    
    return pSimulator;
} // create

Base *Facade::create(const bool& bIsThreaded,
                     const std::string& rLabel,
                     const Properties& rProperties)
{
    Base *pSimulator = new (std::nothrow) CPU(rProperties, true, bIsThreaded);
    
    if(pSimulator != nullptr)
    {
        pSimulator->start();
        
        mbIsGPU = false;
        m_Label = "SIM: " + rLabel;
    } // if
    
    return pSimulator;
} // create

#pragma mark -
#pragma mark Public - Constructor

Facade::Facade(const Types& nType,
               const Properties& rProperties)
{
    mnType   = nType;
    m_Label  = "";
    
    switch(mnType)
    {
        case eComputeCPUSingle:
            mpSimulator = create(false, "Vector Single Core CPU", rProperties);
            break;
            
        case eComputeCPUMulti:
            mpSimulator = create(true, "Vector Multi Core CPU", rProperties);
            break;
            
        case eComputeGPUSecondary:
            mpSimulator = create(1, rProperties);
            break;
            
        case eComputeGPUPrimary:
        default:
            mpSimulator = create(0, rProperties);
            break;
    } // switch
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Facade::~Facade()
{
    if(mpSimulator != nullptr)
    {
        mpSimulator->exit();
        
        delete mpSimulator;
        
        mpSimulator = nullptr;
    } // if
    
    m_Label.clear();
} // Destructor

#pragma mark -
#pragma mark Public - Utilities - Simulator

void Facade::pause()
{
    mpSimulator->pause();
} // pause

void Facade::unpause()
{
    mpSimulator->unpause();
} // unpause

void Facade::resetProperties(const Properties& rProperties)
{
    mpSimulator->resetProperties(rProperties);
} // resetProperties

void Facade::invalidate(const bool& doInvalidate)
{
    mpSimulator->invalidate(doInvalidate);
} // invalidate

GLfloat *Facade::data()
{
    return mpSimulator->data();
} // data

Base* Facade::simulator()
{
    return mpSimulator;
} // simulator

#pragma mark -
#pragma mark Public - Accessors - Quaries

const bool Facade::isActive() const
{
    return mpSimulator != nullptr;
} // isActive

const bool Facade::isAcquired() const
{
    return mpSimulator->isAcquired();
} // isAcquired

const bool Facade::isPaused() const
{
    return mpSimulator->isPaused();
} // isPaused

const bool Facade::isStopped() const
{
    return mpSimulator->isStopped();
} // isStopped

// Is single core cpu simulator active?
const bool Facade::isCPUSingleCore() const
{
    return mnType == eComputeCPUSingle;
} // isCPUSingleCore

// Is multi-core cpu simulator active?
const bool Facade::isCPUMultiCore() const
{
    return mnType == eComputeCPUMulti;
} // isCPUMultiCore

// Is primary gpu simulator active?
const bool Facade::isGPUPrimary() const
{
    return mnType == eComputeGPUPrimary;
} // isGPUPrimary

// Is secondary (or offline) gpu simulator active?
const bool Facade::isGPUSecondary() const
{
    return mnType == eComputeGPUSecondary;
} // isGPUSecondary

#pragma mark -
#pragma mark Public - Accessors - Getters

void Facade::positionInRange(GLfloat *pDst)
{
    mpSimulator->positionInRange(pDst);
} // positionInRange

void Facade::position(GLfloat *pDst)
{
    mpSimulator->position(pDst);
} // position

void Facade::velocity(GLfloat *pDst)
{
    mpSimulator->velocity(pDst);
} // velocity

const GLdouble Facade::performance() const
{
    return mpSimulator->performance();
} // performance

const GLdouble Facade::updates() const
{
    return mpSimulator->updates();
} // updates

const GLdouble Facade::year() const
{
    return mpSimulator->year();
} // year

const size_t Facade::size() const
{
    return mpSimulator->size();
} // size

const std::string& Facade::label() const
{
    return m_Label;
} // label

const Types& Facade::type() const
{
    return mnType;
} // type

#pragma mark -
#pragma mark Public - Accessors - Setters

void Facade::setRange(const GLint& min,
                      const GLint& max)
{
    mpSimulator->setRange(min, max);
} // setRange

void Facade::setProperties(const Properties& rProperties)
{
    mpSimulator->setProperties(rProperties);
} // setProperties

void Facade::setData(const GLfloat * const pData)
{
    mpSimulator->setData(pData);
} // setData

void Facade::setPosition(const GLfloat * const pSrc)
{
    mpSimulator->setPosition(pSrc);
} // setPosition

void Facade::setVelocity(const GLfloat * const pSrc)
{
    mpSimulator->setVelocity(pSrc);
} // setVelocity
