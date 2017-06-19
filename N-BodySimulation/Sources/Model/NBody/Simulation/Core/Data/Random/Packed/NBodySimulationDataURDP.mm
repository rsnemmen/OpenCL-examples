/*
 <codex>
 <import>NBodySimulationDataURDP.h</import>
 </codex>
 */

#import "NBodyConstants.h"
#import "NBodySimulationDataGalaxy.h"
#import "NBodySimulationDataURDP.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation::Data;

#pragma mark -
#pragma mark Private - Constants

static const GLfloat kBodyCountScale = 1.0f / 16384.0f;

#pragma mark -
#pragma mark Private - Utilities

void URDP::configExpand(simd::float4* pPosition,
                        simd::float4* pVelocity)
{
    const GLfloat pscale  = m_Scale[0] * std::max(1.0f, mnBCScale);
    const GLfloat vscale = pscale * m_Scale[1];
    
    dispatch_apply(mnParticles, m_DQueue, ^(size_t i) {
        simd::float3 position = pscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->rand();
        simd::float3 velocity = vscale * position;
        
        pPosition[i].xyz = position;
        pPosition[i].w   = 1.0f;
        
        pVelocity[i].xyz = velocity;
        pVelocity[i].w   = 1.0f;
    });
} // configExpand

void URDP::configRandom(simd::float4* pPosition,
                        simd::float4* pVelocity)
{
    const GLfloat pscale = m_Scale[0] * std::max(1.0f, mnBCScale);
    const GLfloat vscale = m_Scale[1] * pscale;
    
    dispatch_apply(mnParticles, m_DQueue, ^(size_t i) {
        pPosition[i].xyz = pscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
        pPosition[i].w   = 1.0f; // mass
        
        pVelocity[i].xyz = vscale * mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
        pVelocity[i].w   = 1.0f; // inverse mass
    });
} // configRandom

void URDP::configShell(simd::float4* pPosition,
                       simd::float4* pVelocity)
{
    const GLfloat pscale = m_Scale[0];
    const GLfloat vscale = pscale * m_Scale[1];
    const GLfloat inner  = 2.5f * pscale;
    const GLfloat outer  = 4.0f * pscale;
    const GLfloat length = outer - inner;

    dispatch_apply(mnParticles, m_DQueue, ^(size_t i) {
        simd::float3 nrpos    = mpGenerator[eNBodyRandIntervalLenIsTwo]->nrand();
        simd::float3 rpos     = mpGenerator[eNBodyRandIntervalLenIsOne]->rand();
        simd::float3 position = nrpos * (inner + (length * rpos));
        
        pPosition[i].xyz = position;
        pPosition[i].w   = mnTCScale;
        
        simd::float3 axis = m_Axis;
        
        GLfloat scalar = simd::dot(nrpos, axis);
        
        if((1.0f - scalar) < 1e-6)
        {
            axis.xy = nrpos.yx;
            
            axis = simd::normalize(axis);
        } // if
        
        simd::float3 velocity = vscale * simd::cross(position, axis);
    
        pVelocity[i].xyz = velocity;
        pVelocity[i].w   = mnVCScale;
    });
} // configShell

void URDP::configMWM31(simd::float4* pPosition,
                       simd::float4* pVelocity)
{
    Data::Galaxy df(mnParticles);
    
    if(df.rows())
    {
        // The Milky-Way (MW) seems to be on a collision course with our
        // neighbour spiral galaxy Andromeda (M31)
        
        GLfloat pscale = m_Scale[0];
        GLfloat vscale = pscale * m_Scale[1];
        GLfloat mscale = pscale * pscale * pscale;
        
        GLint numPoints = 0;
        
        GLfloat mass = 0.0f;
        
        simd::float3 position = 0.0f;
        simd::float3 velocity = 0.0f;
        
        size_t i = 0;
        
        while(!df.eof())
        {
            numPoints++;
            
            std::vector<float> vec = df.floats();
            
            mass = vec[0] * mscale;

            position = {vec[1], vec[2], vec[3]};
            
            pPosition[i].xyz = pscale * position;
            pPosition[i].w   = mass;
            
            velocity = {vec[4], vec[5], vec[6]};
            
            pVelocity[i].xyz = vscale * velocity;
            pVelocity[i].w   = 1.0f / mass;
        } // while
    } // if
} // configMWM31

#pragma mark -
#pragma mark Public - Interfaces

URDP::URDP(const Properties& rProperties)
: URDB::URDB(rProperties)
{
    mnCount   = GLfloat(mnParticles);
    mnBCScale = mnCount / 1024.0f;
    mnTCScale = 16384.0f / mnCount;
    mnVCScale = kBodyCountScale * mnCount;
} // Constructor

URDP::~URDP()
{
    mnCount   = 0.0f;
    mnBCScale = 0.0f;
    mnTCScale = 0.0f;
    mnVCScale = 0.0f;
} // Destructor

bool URDP::operator()(GLfloat* pInPosition,
                      GLfloat* pInVelocity)
{
    bool bSuccess = (pInPosition != nullptr) && (pInVelocity != nullptr);
    
    if(bSuccess)
    {
        simd::float4* pPosition = reinterpret_cast<simd::float4 *>(pInPosition);
        simd::float4* pVelocity = reinterpret_cast<simd::float4 *>(pInVelocity);

        switch(mnConfig)
        {
            case NBody::eConfigShell:
                configShell(pPosition, pVelocity);
                break;
                
            case NBody::eConfigMWM31:
                configMWM31(pPosition, pVelocity);
                break;
                
            case NBody::eConfigExpand:
                configExpand(pPosition, pVelocity);
                break;
                
            case NBody::eConfigRandom:
            default:
                configRandom(pPosition, pVelocity);
                break;
        } // switch
    } // if
    
    return bSuccess;
} // operator()
