/*
 <codex>
 <abstract>
 Functor for generating random packed data sets for the cpu or gpu bound simulator.
 </abstract>
 </codex>
 */

#ifndef _NBODY_SIMULATION_DATA_GALAXY_H_
#define _NBODY_SIMULATION_DATA_GALAXY_H_

#import "CFDataFile.h"

#import "NBodySimulationProperties.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            class Galaxy
            {
            public:
                // Acquire the galaxy file using properties
                Galaxy(const size_t nParticles = 16384);
            
                // Copy constructor for deep-copy
                Galaxy(const Galaxy& rGalaxy);
                
                // Delete the object
                virtual ~Galaxy();
                
                // Assignment operator for deep object copy
                Galaxy& operator=(const Galaxy& rGalaxy);

                // End-of-File
                const bool eof() const;
                
                // Row count
                const size_t rows() const;
                
                // Column count
                const size_t columns() const;
                
                // File length, or the number of bytes
                const size_t length()  const;
                
                // Current line
                const size_t line() const;
                
                // Float vector from a line in the data file
                std::vector<float> floats();
                
                // Double vector from a line in the data file
                std::vector<double> doubles();
                
                // Reset the file content pointer to the beginning, past the header
                void reset();
                
            private:
                CF::DataFile* create(const size_t& nParticles);
                
            private:
                size_t        mnParticles;
                CF::DataFile* mpData;
            }; // Galaxy
        } // Data
    } // Simulation
} // NBody

#endif

#endif
