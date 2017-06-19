/*
 <codex>
 <import>NBodySimulationGPU.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import "GLMSizes.h"

#import "CFFile.h"

#import "NBodySimulationDataURDP.h"
#import "NBodySimulationGPU.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Constants

static GLuint kWorkItemsX = 256;
static GLuint kWorkItemsY = 1;

static const size_t kKernelParams = 11;
static const size_t kSizeCLMem    = sizeof(cl_mem);

static const char* kIntegrateSystem = "IntegrateSystem";

#pragma mark -
#pragma mark Private - Utilities

static GLint NBodySimulationGPUReadBuffer(cl_command_queue compute_commands,
                                          GLfloat *host_data,
                                          cl_mem device_data,
                                          size_t size,
                                          size_t offset)
{
    return clEnqueueReadBuffer(compute_commands,
                               device_data,
                               CL_TRUE,
                               offset,
                               size,
                               host_data,
                               0,
                               nullptr,
                               nullptr);
} // NBodySimulationGPUReadBuffer

static GLint NBodySimulationGPUWriteBuffer(cl_command_queue compute_commands,
                                           const GLfloat * const host_data,
                                           cl_mem device_data,
                                           size_t size)
{
    return clEnqueueWriteBuffer(compute_commands,
                                device_data,
                                CL_TRUE,
                                0,
                                size,
                                host_data,
                                0,
                                nullptr,
                                nullptr);
} // NBodySimulationGPUWriteBuffer

GLint GPU::bind()
{
    GLint err = CL_INVALID_KERNEL;
    
    if(mpKernel != nullptr)
    {
        GLuint i = 0;
        
        size_t  sizes[kKernelParams];
        void*   pValues[kKernelParams];
        
        pValues[0]  = &mpDevicePosition[mnWriteIndex];
        pValues[1]  = &mpDeviceVelocity[mnWriteIndex];
        pValues[2]  = &mpDevicePosition[mnReadIndex];
        pValues[3]  = &mpDeviceVelocity[mnReadIndex];
        pValues[4]  = (void *) &m_Properties.mnTimeStep;
        pValues[5]  = (void *) &m_Properties.mnDamping;
        pValues[6]  = (void *) &m_Properties.mnSoftening;
        pValues[7]  = (void *) &m_Properties.mnParticles;
        pValues[8]  = &mnMinIndex;
        pValues[9]  = &mnMaxIndex;
        pValues[10] = nullptr;
        
        sizes[0]  = kSizeCLMem;
        sizes[1]  = kSizeCLMem;
        sizes[2]  = kSizeCLMem;
        sizes[3]  = kSizeCLMem;
        sizes[4]  = mnSamples;
        sizes[5]  = mnSamples;
        sizes[6]  = mnSamples;
        sizes[7]  = GLM::Size::kInt;
        sizes[8]  = GLM::Size::kInt;
        sizes[9]  = GLM::Size::kInt;
        sizes[10] = 4 * mnSamples * mnWorkItemX * kWorkItemsY;
        
        for (i = 0; i < kKernelParams; ++i)
        {
            err = clSetKernelArg(mpKernel, i, sizes[i], pValues[i]);
            
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
    } // if
    
    return err;
} // restart

GLint GPU::setup(const std::string& options)
{
    cl_mem_flags file_flags = CL_MEM_READ_WRITE;
    
    GLuint i = mnDeviceIndex;
    
    GLint err = CL_SUCCESS;
    
    err = clGetDeviceIDs(nullptr, CL_DEVICE_TYPE_GPU, 4, mpDevice, &mnDevices);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    std::cout
    << ">> N-body Simulation: Found "
    << mnDevices
    << " devices..."
    << std::endl;
    
    size_t nSize = 0;
    
    char name[1024]   = {0};
    char vendor[1024] = {0};
    
    clGetDeviceInfo(mpDevice[i],
                    CL_DEVICE_NAME,
                    sizeof(name),
                    &name,
                    &nSize);
    
    clGetDeviceInfo(mpDevice[i],
                    CL_DEVICE_VENDOR,
                    sizeof(vendor),
                    &vendor,
                    &nSize);
    
    m_DeviceName = name;
    
    std::cout
    << ">> N-body Simulation: Using Device["
    << i
    << "] = \""
    << m_DeviceName
    << "\""
    << std::endl;
    
    mpDevice[0] = mpDevice[i];
    
    mpContext = clCreateContext(nullptr,
                                1,
                                &mpDevice[0],
                                nullptr,
                                nullptr,
                                &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    mpQueue[0] = clCreateCommandQueue(mpContext,
                                      mpDevice[0],
                                      0,
                                      &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    CF::File file(CFSTR("nbody_gpu"), CFSTR("ocl"));
    
    const CFIndex  nLength = file.length();
    
    if(!nLength)
    {
        return CL_INVALID_VALUE;
    } // if
    
    std::string source  = file.string();
    const char* pSource = source.c_str();
    
    mpProgram = clCreateProgramWithSource(mpContext,
                                          1,
                                          &pSource,
                                          nullptr,
                                          &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    const char *pOptions = !options.empty() ? options.c_str() : nullptr;
    
    err = clBuildProgram(mpProgram,
                         mnDeviceCount,
                         mpDevice,
                         pOptions,
                         nullptr,
                         nullptr);
    
    if(err != CL_SUCCESS)
    {
        size_t length = 0;
        
        char info_log[2000];
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            clGetProgramBuildInfo(mpProgram,
                                  mpDevice[i],
                                  CL_PROGRAM_BUILD_LOG,
                                  2000,
                                  info_log,
                                  &length);
            
            std::cerr
            << ">> N-body Simulation: Build Log for Device ["
            << i
            << "]:"
            << std::endl
            << info_log
            << std::endl;
        } // for
        
        return err;
    } // if
    
    mpKernel = clCreateKernel(mpProgram,
                              kIntegrateSystem,
                              &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    size_t localSize = 0;
    
    for(i = 0; i < mnDeviceCount; ++i)
    {
        err = clGetKernelWorkGroupInfo(mpKernel,
                                       mpDevice[i],
                                       CL_KERNEL_WORK_GROUP_SIZE,
                                       GLM::Size::kULong,
                                       &localSize,
                                       nullptr);
        if(err != CL_SUCCESS)
        {
            return err;
        } // if
        
        mnWorkItemX = GLuint((mnWorkItemX <= localSize) ? mnWorkItemX : localSize);
    } // for
    
    bool isInvalidWorkDim = bool(m_Properties.mnParticles % mnWorkItemX);
    
    if(isInvalidWorkDim)
    {
        std::cerr
        << ">> N-body Simulation: Number of particlces ["
        << m_Properties.mnParticles
        << "] "
        << "must be evenly divisble work group size ["
        << mnWorkItemX
        << "] for device!"
        << std::endl;
        
        return CL_INVALID_WORK_DIMENSION;
    } // if
    
    const size_t size = 4 * GLM::Size::kFloat * m_Properties.mnParticles;
    
    mpDevicePosition[0] = clCreateBuffer(mpContext,
                                         file_flags,
                                         size,
                                         nullptr,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -100;
    } // if
    
    mpDevicePosition[1] = clCreateBuffer(mpContext,
                                         file_flags,
                                         size,
                                         nullptr,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -101;
    } // if
    
    mpDeviceVelocity[0] = clCreateBuffer(mpContext,
                                         CL_MEM_READ_WRITE,
                                         size,
                                         nullptr,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -102;
    } // if
    
    mpDeviceVelocity[1] = clCreateBuffer(mpContext,
                                         CL_MEM_READ_WRITE,
                                         size,
                                         nullptr,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -103;
    } // if
    
    mpBodyRangeParams = clCreateBuffer(mpContext,
                                       CL_MEM_READ_WRITE,
                                       GLM::Size::kInt * 3,
                                       nullptr,
                                       &err);
    
    if(err != CL_SUCCESS)
    {
        return -104;
    } // if
    
    bind();
    
    return 0;
} // setup

GLint GPU::execute()
{
    GLint err = CL_INVALID_KERNEL;
    
    if(mpKernel != nullptr)
    {
        size_t global_dim[2];
        size_t local_dim[2];
        
        local_dim[0]  = mnWorkItemX;
        local_dim[1]  = 1;
        
        global_dim[0] = mnMaxIndex - mnMinIndex;
        global_dim[1] = 1;
        
        void   *values[4];
        size_t  sizes[4];
        GLuint  indices[4];
        
        values[0] = &mpDevicePosition[mnWriteIndex];
        values[1] = &mpDeviceVelocity[mnWriteIndex];
        values[2] = &mpDevicePosition[mnReadIndex];
        values[3] = &mpDeviceVelocity[mnReadIndex];
        
        sizes[0] = kSizeCLMem;
        sizes[1] = kSizeCLMem;
        sizes[2] = kSizeCLMem;
        sizes[3] = kSizeCLMem;
        
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        indices[3] = 3;
        
        GLuint i;
        
        for (i = 0; i < 4; ++i)
        {
            err = clSetKernelArg(mpKernel, indices[i], sizes[i], values[i]);
            
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            if(mpQueue[i] != nullptr)
            {
                err = clEnqueueNDRangeKernel(mpQueue[i],
                                             mpKernel,
                                             2,
                                             nullptr,
                                             global_dim,
                                             local_dim,
                                             0,
                                             nullptr,
                                             nullptr);
                
                if(err != CL_SUCCESS)
                {
                    return err;
                } // if
            } // if
        } // for
    } // if
    
    return err;
} // execute

GLint GPU::restart()
{
    GLint err = CL_INVALID_KERNEL;
    
    if(mpKernel != nullptr)
    {
        NBody::Simulation::Data::URDP urdp(m_Properties);
        
        if(urdp(mpHostPosition, mpHostVelocity))
        {
            const size_t size = 4 * GLM::Size::kFloat * m_Properties.mnParticles;
            
            GLuint i = 0;
            
            for(i = 0; i < mnDeviceCount; ++i)
            {
                if(mpQueue[i] != nullptr)
                {
                    err = clEnqueueWriteBuffer(mpQueue[i],
                                               mpDevicePosition[mnReadIndex],
                                               CL_TRUE,
                                               0,
                                               size,
                                               mpHostPosition,
                                               0,
                                               nullptr,
                                               nullptr);
                    
                    if(err != CL_SUCCESS)
                    {
                        return err;
                    } // if
                    
                    err = clEnqueueWriteBuffer(mpQueue[i],
                                               mpDeviceVelocity[mnReadIndex],
                                               CL_TRUE,
                                               0,
                                               size,
                                               mpHostVelocity,
                                               0,
                                               nullptr,
                                               nullptr);
                    
                    if(err != CL_SUCCESS)
                    {
                        return err;
                    } // if
                } // if
            } // for
            
            bind();
        } // if
    } // if
    
    return err;
} // restart

#pragma mark -
#pragma mark Public - Constructor

GPU::GPU(const NBody::Simulation::Properties& Properties,
         const GLuint& index)
: NBody::Simulation::Base(Properties)
{
    mnDeviceCount = 1;
    mnDeviceIndex = index;
    mnWorkItemX   = kWorkItemsX;
    mbTerminated  = false;
    mnReadIndex   = 0;
    mnWriteIndex  = 0;
    
    mpHostPosition = nullptr;
    mpHostVelocity = nullptr;
    
    mpContext  = nullptr;
    mpProgram  = nullptr;
    mpKernel   = nullptr;
    mpBodyRangeParams = nullptr;
    
    mpDevice[0] = nullptr;
    mpDevice[1] = nullptr;
    
    mpQueue[0] = nullptr;
    mpQueue[1] = nullptr;
    
    mpDevicePosition[0] = nullptr;
    mpDevicePosition[1] = nullptr;
    
    mpDeviceVelocity[0] = nullptr;
    mpDeviceVelocity[1] = nullptr;
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

GPU::~GPU()
{
    stop();
    
    terminate();
} // Destructor

#pragma mark -
#pragma mark Public - Utilities

void GPU::initialize(const std::string& options)
{
    if(!mbTerminated)
    {
        mnReadIndex  = 0;
        mnWriteIndex = 1;
        
        mpHostPosition = (GLfloat *)std::calloc(mnLength, mnSamples);
        mpHostVelocity = (GLfloat *)std::calloc(mnLength, mnSamples);
        
        GLint err = setup(options);
        
        mbAcquired = err == CL_SUCCESS;
        
        if(!mbAcquired)
        {
            std::cerr
            << ">> N-body Simulation["
            << err
            << "]: Failed setting up gpu compute device!"
            << std::endl;
        } // if
    } // if
} // initialize

GLint GPU::reset()
{
    GLint err = restart();
    
    if(err != CL_SUCCESS)
    {
        std::cerr
        << ">> N-body Simulation["
        << err
        << "]: Failed resetting devices!"
        << std::endl;
    } // if
    
    return err;
} // reset

void GPU::step()
{
    if(!isPaused() || !isStopped())
    {
        GLint err = execute();
        
        if(err != CL_SUCCESS)
        {
            std::cerr
            << ">> N-body Simulation["
            << err
            << "]: Failed executing gpu bound kernel!"
            << std::endl;
        } // if
        
        GLuint i  = 0;
        
        if(mbIsUpdated)
        {
            for (i = 0; i < mnDeviceCount; ++i)
            {
                NBodySimulationGPUReadBuffer(mpQueue[i],
                                             mpHostPosition,
                                             mpDevicePosition[mnWriteIndex],
                                             mnSize,
                                             0);
                
                setData(mpHostPosition);
            } // for
        } // if
        
        std::swap(mnReadIndex, mnWriteIndex);
    } // if
} // step

void GPU::terminate()
{
    if(!mbTerminated)
    {
        GLuint i = 0;
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            if(mpQueue[i] != nullptr)
            {
                clFinish(mpQueue[i]);
            } // if
        } // for
        
        if(mpDevicePosition[0] != nullptr)
        {
            clReleaseMemObject(mpDevicePosition[0]);
            
            mpDevicePosition[0] = nullptr;
        } // if
        
        if(mpDevicePosition[1] != nullptr)
        {
            clReleaseMemObject(mpDevicePosition[1]);
            
            mpDevicePosition[1] = nullptr;
        } // if
        
        if(mpDeviceVelocity[0] != nullptr)
        {
            clReleaseMemObject(mpDeviceVelocity[0]);
            
            mpDeviceVelocity[0] = nullptr;
        } // if
        
        if(mpDeviceVelocity[1] != nullptr)
        {
            clReleaseMemObject(mpDeviceVelocity[1]);
            
            mpDeviceVelocity[1] = nullptr;
        } // if
        
        if(mpBodyRangeParams != nullptr)
        {
            clReleaseMemObject(mpBodyRangeParams);
            
            mpBodyRangeParams = nullptr;
        } // if
        
        if(mpKernel != nullptr)
        {
            clReleaseKernel(mpKernel);
            
            mpKernel = nullptr;
        } // if
        
        if(mpProgram != nullptr)
        {
            clReleaseProgram(mpProgram);
            
            mpProgram = nullptr;
        } // if
        
        if(mpContext != nullptr)
        {
            clReleaseContext(mpContext);
            
            mpContext = nullptr;
        } // if
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            if(mpQueue[i] != nullptr)
            {
                clReleaseCommandQueue(mpQueue[i]);
                
                mpQueue[i] = nullptr;
            } // if
        } // for
        
        if(mpHostPosition != nullptr)
        {
            std::free(mpHostPosition);
            
            mpHostPosition = nullptr;
        } // if
        
        if(mpHostVelocity != nullptr)
        {
            std::free(mpHostVelocity);
            
            mpHostVelocity = nullptr;
        } // if
        
        mbTerminated = true;
    } // if
} // terminate

#pragma mark -
#pragma mark Public - Accessors

GLint GPU::positionInRange(GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != nullptr)
    {
        size_t data_offset_in_floats = mnMinIndex * 4;
        size_t data_offset_bytes     = data_offset_in_floats * mnSamples;
        size_t data_size_in_floats   = (mnMaxIndex - mnMinIndex) * 4;
        size_t data_size_bytes       = data_size_in_floats * mnSamples;
        
        GLuint i = 0;
        
        GLfloat *host_data = pDst + data_offset_in_floats;
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUReadBuffer(mpQueue[i],
                                               host_data,
                                               mpDevicePosition[mnReadIndex],
                                               data_size_bytes,
                                               data_offset_bytes);
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
    } // if
    
    return err;
} // positionInRange

GLint GPU::position(GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != nullptr)
    {
        size_t i;
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUReadBuffer(mpQueue[i],
                                               pDst,
                                               mpDevicePosition[mnReadIndex],
                                               mnSize,
                                               0);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // position

GLint GPU::setPosition(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != nullptr)
    {
        size_t i;
        
        for (i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUWriteBuffer(mpQueue[i],
                                                pSrc,
                                                mpDevicePosition[mnReadIndex],
                                                mnSize);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // setPosition

GLint GPU::velocity(GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != nullptr)
    {
        size_t i;
        
        for (i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUReadBuffer(mpQueue[i],
                                               pDst,
                                               mpDeviceVelocity[mnReadIndex],
                                               mnSize,
                                               0);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // velocity

GLint GPU::setVelocity(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != nullptr)
    {
        size_t i;
        
        for (i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUWriteBuffer(mpQueue[i],
                                                pSrc,
                                                mpDeviceVelocity[mnReadIndex],
                                                mnSize);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // setVelocity
