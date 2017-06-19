/*
 <codex>
 <import>CFProcessorInfoArray.h</import>
 </codex>
 */

#include <mach/vm_map.h>

#import "CFProcessorInfoArray.h"

typedef vm_address_t * vm_address_ref;

processor_info_array_t CF::ProcessorInfoArrayCreate(const natural_t& nSize,
                                                    kern_return_t& err)
{
    processor_info_array_t pInfo = nullptr;
    
    err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
    
    if(err == KERN_SUCCESS)
    {
        err = vm_allocate(mach_task_self(),
                          vm_address_ref(&pInfo),
                          nSize,
                          VM_FLAGS_ANYWHERE);
    } // if
    
    return pInfo;
} // ProcessorInfoArrayCreate

processor_info_array_t CF::ProcessorInfoArrayCreateCopy(const natural_t& nSizeDst,
                                                        processor_info_array_t pInfoSrc,
                                                        kern_return_t& err)
{
    processor_info_array_t pInfoDst = nullptr;
    
    err = (nSizeDst) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;

    if(err == KERN_SUCCESS)
    {
        err = vm_allocate(mach_task_self(),
                          vm_address_ref(&pInfoDst),
                          nSizeDst,
                          VM_FLAGS_ANYWHERE);
        
        if(err == KERN_SUCCESS)
        {
            err = vm_copy(mach_task_self(),
                          vm_address_t(pInfoSrc),
                          nSizeDst,
                          vm_address_t(pInfoDst));
        } // if
    } // if
    
    return pInfoDst;
} // ProcessorInfoArrayCreateCopy

kern_return_t CF::ProcessorInfoArrayCopy(const natural_t& nSize,
                                         processor_info_array_t pInfoSrc,
                                         processor_info_array_t pInfoDst)
{
    kern_return_t err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
    
    if(err == KERN_SUCCESS)
    {
        err = vm_copy(mach_task_self(),
                      vm_address_t(pInfoSrc),
                      nSize,
                      vm_address_t(pInfoDst));
    } // if
    
    return err;
} // ProcessorInfoArrayCopy

kern_return_t CF::ProcessorInfoArrayDelete(const natural_t& nSize,
                                           processor_info_array_t pInfo)
{
    kern_return_t err = (nSize) ? KERN_SUCCESS : KERN_INVALID_ARGUMENT;
    
    if(err == KERN_SUCCESS)
    {
        err = vm_deallocate(mach_task_self(), vm_address_t(pInfo), nSize);
        
        pInfo = nullptr;
    } // if
    
    return err;
} // ProcessorInfoArrayDelete
