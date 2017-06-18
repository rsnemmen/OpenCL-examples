#define ARRAY_SIZE 100000000

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main() {

   int i,j;
   float input[ARRAY_SIZE], output[ARRAY_SIZE];
   float x;




// Computes the Mandelbrot Set to N Iterations
void solve_mandelbrot(std::vector<float> const & real,
                      std::vector<float> const & imag,
                      int iterations,
                      std::vector<int> & result)
{
    for(unsigned int i = 0; i < real.size(); i++)
    {
        float x = real[i]; // Real Component
        float y = imag[i]; // Imaginary Component
        int   n = 0;       // Tracks Color Information

        // Compute the Mandelbrot Set
        while ((x * x + y * y <= 2 * 2) && n < iterations)
        {
            float xtemp = x * x - y * y + real[i];
            y = 2 * x * y + imag[i];
            x = xtemp;
            n++;
        }

        // Write Results to Output Arrays
        result[i] = x * x + y * y <= 2 * 2 ? -1 : n;
    }
}





   /* Initialize data */
   for(i=0; i<ARRAY_SIZE; i++) {
      input[i] = 1.0f*i;
   }

   // Perform computation
   for (i=0; i<ARRAY_SIZE; i++) {
      // Waste computing on purpose
      for (j=0; j<1000000; j++) {
         x=(float)j;
      }

      for (j=0; j<1000000; j++) {
         x=x*x*x+x+x/3.;
      }      
      
      output[i]=input[i]*input[i];
   }

   return 0;
}
