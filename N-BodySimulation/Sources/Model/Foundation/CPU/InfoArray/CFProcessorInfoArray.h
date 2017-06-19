/*
 <codex>
 <abstract>
 Utility methods for processor info array management.
 </abstract>
 </codex>
 */

#ifndef _CORE_FOUNDATION_PROCESSOR_INFO_ARRAY_H_
#define _CORE_FOUNDATION_PROCESSOR_INFO_ARRAY_H_

#import <mach/mach.h>

#ifdef __cplusplus

namespace CF
{
    processor_info_array_t ProcessorInfoArrayCreate(const natural_t& nSize,
                                                    kern_return_t& err);
    
    processor_info_array_t ProcessorInfoArrayCreateCopy(const natural_t& nSizeDst,
                                                        processor_info_array_t pInfoSrc,
                                                        kern_return_t& err);
    
    kern_return_t ProcessorInfoArrayCopy(const natural_t& nSize,
                                         processor_info_array_t pInfoSrc,
                                         processor_info_array_t pInfoDst);
    
    kern_return_t ProcessorInfoArrayDelete(const natural_t& nSize,
                                           processor_info_array_t pInfo);
} // CF

#endif

#endif

