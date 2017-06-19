/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility functor for creating dispatch queues with a unique identifier
 */


#ifndef _CORE_FOUNDATION_QUEUE_H_
#define _CORE_FOUNDATION_QUEUE_H_

#import <random>
#import <string>

#import <Foundation/Foundation.h>

#ifdef __cplusplus

namespace CF
{
    class Queue
    {
    public:
        Queue(const dispatch_queue_attr_t& attribute = DISPATCH_QUEUE_SERIAL);
        
        virtual ~Queue();
        
        const std::string identifier() const;
        
        dispatch_queue_t operator()(const std::string& label);
        
    public:
        dispatch_queue_attr_t attribute;  // Dispatch queue attribute

    private:
        
        std::string        m_SQID;      // Dispatch queue label plus an attched id
        std::random_device m_Device;    // A device for random number generation
    };
} // Queue

#endif

#endif
