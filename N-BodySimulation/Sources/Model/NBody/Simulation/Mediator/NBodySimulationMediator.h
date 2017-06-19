/*
 <codex>
 <abstract>
 A mediator object for managing cpu and gpu bound simulators, along with their labeled-buttons.
 </abstract>
 </codex>
 */

#ifndef _OpenCL_NBody_Simulation_Mediator_H_
#define _OpenCL_NBody_Simulation_Mediator_H_

#import "NBodySimulationFacade.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class Mediator
        {
        public:
            // Construct a mediator object for GPUs, or CPU and CPUs
            Mediator(const Properties& rProperties);
            
            // Delete alll simulators
            virtual ~Mediator();
        
            // Select the current simulator to use
            void select(const GLuint& index);

            // Select the current simulator to use
            void select(const Types& type);
                        
            // Get the current simulator
            Facade* simulator();
            
            // Reset all the gpu bound simulators
            void reset();
            
            // void update position data
            void update();

            // Pause the current active simulator
            void pause();
            
            // unpause the current active simulator
            void unpause();
            
            // Accessor Methods for the active simulator
            const GLdouble  performance() const;
            const GLdouble  updates()     const;
            
            // Get the total number of simulators
            const GLuint count() const;
            
            // Get position data
            const GLfloat* position() const;
            
            // Active simulator query
            const bool isCPUSingleCore() const;
            const bool isCPUMultiCore()  const;
            const bool isGPUPrimary()    const;
            const bool isGPUSecondary()  const;
            
            // Label for a type of simulator
            const std::string& label(const Types& nType) const;

            // Active simulator type
            const Types& type() const;

            // Check to see if position was acquired
            const bool hasPosition() const;
                       
        private:
             // Acquire all simulators
            void acquire(const Properties& rProperties);
            
            // Initialize all instance variables to their default values
            void setDefaults(const Properties& rProperties);
            
            // Set the defaults for simulator compute
            void setCompute(const Properties& rProperties);

        private:
            bool        mbCPUs;
            size_t      mnParticles;
            size_t      mnSize;
            GLuint      mnCount;
            GLuint      mnGPUs;
            GLfloat*    mpPosition;
            Types       mnActive;
            Properties  m_Properties;
            Facade*     mpSimulators[eComputeMax];
            Facade*     mpActive;
        }; // Mediator
    } // Simulation
} // NBody

#endif

#endif
