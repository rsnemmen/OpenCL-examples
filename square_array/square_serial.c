#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main() {

   long long int ARRAY_SIZE=10000000000; // size of arrays
   long long int i;
   float input[ARRAY_SIZE], output[ARRAY_SIZE];

   /* Initialize data */
   for(i=0; i<ARRAY_SIZE; i++) {
      input[i] = 1.0f*i;
   }

   // Perform computation
   for (i=0; i<ARRAY_SIZE; i++) {
      output[i]=input[i]*input[i];
   }

   return 0;
}
