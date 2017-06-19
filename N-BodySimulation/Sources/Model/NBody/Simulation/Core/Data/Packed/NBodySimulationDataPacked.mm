/*
 <codex>
 <import>NBodySimulationDataPacked.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cstdlib>

#import "NBodySimulationDataPacked.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Constants

static const size_t kNBodySimPackedDataMemSize = sizeof(cl_mem);

#pragma mark -
#pragma mark Private - Data Structures

struct Data::Packed3D
{
    GLfloat* mpHost;
    cl_mem   mpDevice;
};

#pragma mark -
#pragma mark Public - Constructor

Data::Packed::Packed(const Properties& rProperties)
{
    mnParticles = rProperties.mnParticles;
    mnLength    = 4 * mnParticles;
    mnSamples   = sizeof(GLfloat);
    mnSize      = mnLength * mnSamples;
    mnFlags     = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR);
    mpPacked    = Data::Packed3DRef(std::calloc(1, sizeof(Data::Packed3D)));
    
    if(mpPacked != nullptr)
    {
        mpPacked->mpHost = (GLfloat *)std::calloc(mnLength, mnSamples);
    } // if
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Data::Packed::~Packed()
{
    if(mpPacked != nullptr)
    {
        if(mpPacked->mpHost != nullptr)
        {
            std::free(mpPacked->mpHost);
            
            mpPacked->mpHost = nullptr;
        } // if
        
        if(mpPacked->mpDevice != nullptr)
        {
            clReleaseMemObject(mpPacked->mpDevice);
            
            mpPacked->mpDevice = nullptr;
        } // if
        
        std::free(mpPacked);
        
        mpPacked = nullptr;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLfloat* Data::Packed::data() const
{
    return mpPacked->mpHost;
} // data

#pragma mark -
#pragma mark Public - Utilities

GLfloat* Data::Packed::data()
{
    return mpPacked->mpHost;
} // data

GLint Data::Packed::acquire(cl_context pContext)
{
    GLint err = CL_INVALID_CONTEXT;
    
    if(pContext != nullptr)
    {
        mpPacked->mpDevice = clCreateBuffer(pContext,
                                            mnFlags,
                                            mnSize,
                                            mpPacked->mpHost,
                                            &err);
        
        if(err != CL_SUCCESS)
        {
            return -301;
        } // if
    } // if
    
    return err;
} // setup

GLint Data::Packed::bind(const cl_uint& nIndex,
                         cl_kernel pKernel)
{
    GLint err = CL_INVALID_KERNEL;
    
    if(pKernel != nullptr)
    {
        void*  pValue = &mpPacked->mpDevice;
        size_t nSize  = kNBodySimPackedDataMemSize;
        
        err = clSetKernelArg(pKernel,
                             nIndex,
                             nSize,
                             pValue);
        
        if(err != CL_SUCCESS)
        {
            return err;
        } // if
    } // if
    
    return err;
} // bind

GLint Data::Packed::update(const cl_uint& nIndex,
                           cl_kernel pKernel)
{
    GLint err = CL_INVALID_KERNEL;
    
    if(pKernel != nullptr)
    {
        size_t  nSize  = kNBodySimPackedDataMemSize;
        void*   pValue = &mpPacked->mpDevice;
        
        err = clSetKernelArg(pKernel, nIndex, nSize, pValue);
        
        if(err != CL_SUCCESS)
        {
            return err;
        } // if
    } // if
    
    return err;
} // bind
