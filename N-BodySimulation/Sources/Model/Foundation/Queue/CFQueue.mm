/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility functor for creating dispatch queues with a unique identifier
 */

#import <strstream>

#include "CFQueue.h"

CF::Queue::Queue(const dispatch_queue_attr_t& attrib)
{
    attribute = attrib;
    m_SQID    = "";
} // Constructor

CF::Queue::~Queue()
{
    attribute = nullptr;
    m_SQID    = "";
} // Destructor

const std::string CF::Queue::identifier() const
{
    return m_SQID;
} // identifier

dispatch_queue_t CF::Queue::operator()(const std::string& label)
{
    uint64_t qid = m_Device();
    
    std::strstream sqid;
    
    sqid << qid;
    
    if(label.empty())
    {
        m_SQID = sqid.str();
    } // if
    else
    {
        m_SQID  = label + ".";
        m_SQID += sqid.str();
    } // else
    
    m_SQID += "\0";
    
    return dispatch_queue_create(m_SQID.c_str(), attribute);
} // Operator()
