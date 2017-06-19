/*
 <codex>
 <abstract>
 Utility class for calculating load on CPU cores.
 </abstract>
 </codex>
 */

#ifndef _CORE_FOUNDATION_CPU_LOAD_H_
#define _CORE_FOUNDATION_CPU_LOAD_H_

#import <cstdlib>

#ifdef __cplusplus

namespace CF
{
    namespace CPU
    {
        class Load
        {
        public:
            Load();
            
            Load(const Load& rLoad);

            virtual ~Load();
            
            Load& operator=(const Load& rLoad);
            
            const size_t total() const;
            const size_t user()  const;
            
            double percentage();
        
        private:
            size_t mnTotalTime;
            size_t mnUserTime;
        }; // Load
    } // CPU
} // CF

#endif

#endif

