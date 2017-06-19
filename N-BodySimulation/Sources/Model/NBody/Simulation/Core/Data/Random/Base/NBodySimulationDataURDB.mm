/*
 <codex>
 <import>NBodySimulationDataURDB.h</import>
 </codex>
 */

#import <iostream>

#import "CFQueue.h"

#import "NBodyConstants.h"
#import "NBodySimulationDataURDB.h"

using namespace NBody::Simulation::Data;

URDB::URDB(const Properties& rProperties)
{
    CF::Queue queue;
    
    m_DQueue = queue("com.apple.nbody.simulation.data.urdb");

    m_Axis = {0.0f, 0.0f, 1.0f};
    
    mnParticles = rProperties.mnParticles;
    mnConfig    = rProperties.mnConfig;
    
    m_Scale[0] = rProperties.mnClusterScale;
    m_Scale[1] = rProperties.mnVelocityScale;
    
    mpGenerator[eNBodyRandIntervalLenIsOne] = new (std::nothrow) CM::URD3::generator();
    mpGenerator[eNBodyRandIntervalLenIsTwo] = new (std::nothrow) CM::URD3::generator(-1.0f, 1.0f, 1.0f);
} // Constructor

URDB::~URDB()
{
    mnParticles = 0;
    mnConfig = eConfigRandom;
    
    m_Axis = 0.0f;
    
    m_Scale[0] = 0.0f;
    m_Scale[1] = 0.0f;
    
    if(mpGenerator[eNBodyRandIntervalLenIsOne] != nullptr)
    {
        delete mpGenerator[eNBodyRandIntervalLenIsOne];
        
        mpGenerator[eNBodyRandIntervalLenIsOne] = nullptr;
    } // if
    
    if(mpGenerator[eNBodyRandIntervalLenIsTwo] != nullptr)
    {
        delete mpGenerator[eNBodyRandIntervalLenIsTwo];
        
        mpGenerator[eNBodyRandIntervalLenIsTwo] = nullptr;
    } // if
    
    if(m_DQueue != nullptr)
    {
        dispatch_release(m_DQueue);
        
        m_DQueue = nullptr;
    } // if
} // Destructor

const simd::float3& URDB::axis() const
{
    return m_Axis;
} // axis

void URDB::setAxis(const simd::float3& axis)
{
    m_Axis = simd::normalize(axis);
} // setAxis

void URDB::setProperties(const Properties& rProperties)
{
    mnParticles = rProperties.mnParticles;
    mnConfig = rProperties.mnConfig;
    
    m_Scale[0] = rProperties.mnClusterScale;
    m_Scale[1] = rProperties.mnVelocityScale;
} // setProperties
