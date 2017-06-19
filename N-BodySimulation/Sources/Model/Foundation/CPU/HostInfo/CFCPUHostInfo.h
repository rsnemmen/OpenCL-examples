/*
 <codex>
 <abstract>
 Utility class for acquiring host (cpu) info array.
 </abstract>
 </codex>
 */

#ifndef _CORE_FOUNDATION_CPU_HOST_INFO_H_
#define _CORE_FOUNDATION_CPU_HOST_INFO_H_

#import <mach/mach.h>

#ifdef __cplusplus

namespace CF
{
    namespace CPU
    {
        class HostInfo
        {
        public:
            HostInfo();
            
            HostInfo(const HostInfo& rHostInfo);
            
            virtual ~HostInfo();
            
            HostInfo& operator=(const HostInfo& rHostInfo);
            
            const kern_return_t error() const;
            
            const processor_flavor_t flavor() const;
            
            const natural_t cpus() const;
            const natural_t size() const;
            
            const natural_t user(const uint32_t& i)   const;
            const natural_t system(const uint32_t& i) const;
            const natural_t idle(const uint32_t& i)   const;
            const natural_t nice(const uint32_t& i)   const;
            
            const size_t total(const uint32_t& i) const;
            
        private:
            natural_t              mnCount;
            natural_t              mnSize;
            processor_flavor_t     mnFlavor;
            kern_return_t          mnError;
            processor_info_array_t mpInfo;
            mach_msg_type_number_t mnInfo;
        }; // HostInfo
    } // CPU
} // CF

#endif

#endif

