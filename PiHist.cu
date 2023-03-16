/**
 * This program implements a parallel code via a kernel function call that computes the distribution of the digits of Pi
 * using hierarchical atomic strategy.
 *
 * Users are expected to enter three arguments: the executable file, the filename that contains 10 million digits of pi,
 * and the number of digits to be evaluated.
 *
 * @author Richard Zhang {zhank20@wfu.edu}
 * @date Mar.15, 2023
 * @assignment Lab 3
 * @course CSC 347
 **/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 1024

__global__ void computeFrequency(int* de_frequency, char* de_digits, int numDigits) {
    // Initialize shared memory for de_frequency
    __shared__ int local[10];

    for (int i = 0; i < 10; i ++) {
        local[i] = 0;
    }
    __syncthreads();

    // Update shared de_frequency
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    // Calculate the digits we need to skip because one thread only need to compute a part of all the digits that need to be processed

    char digit = de_digits[index];
    if (index < numDigits && digit >= '0' && digit <= '9') {
        local[digit-'0']++;
    }
    __syncthreads();

    // Update global de_frequency with shared local array
    for (int i = 0; i < 10; i++) {
        atomicAdd(&(de_frequency[i]), local[i]);
        printf("test: %d", local[i]);
    }
    printf("fuku %d", 1);
}

int main(int argc, char *argv[]) {
    // Determine if there are two arguments on the command line
    if (argc != 3) {
        printf("Command line arguments are not enough: %s \n", argv[0]);
        return 1;
    }

    // Convert the third argument to integer
    int numDigits = atoi(argv[2]);

    // Determine if the number of digits entered by users is legitimate
    if (numDigits <= 0) {
        printf("Number of digits should not be less than 1\n");
        return 2;
    }

    // Check if we can open the file. If not, return error message
    FILE *fp;
    fp = fopen(argv[1], "r");
    if (fp == NULL) {
        printf("%s could not be opened\n", argv[1]);
        exit(1);
    }

    // Allocate memory for digit buffer and read in the digits
    char *digits = (char *) malloc(numDigits * sizeof(char));
    // Pass all the number read to the array digits
    fread(digits, sizeof(char), numDigits, fp);

    // Allocate memory for de_frequency
    int *de_frequency;
    int *frequency;
    frequency=(int*)malloc(10*sizeof(int));
    cudaMalloc((void**)&de_frequency, 10 * sizeof(int));
    cudaMemset(de_frequency, 0, 10 * sizeof(int));

    // Compute the distribution of digits using CUDA kernel
    int gridSize = (numDigits + BLOCK_SIZE - 1) / BLOCK_SIZE;
    int blockSize = BLOCK_SIZE;
    computeFrequency<<<gridSize, blockSize>>>(de_frequency, digits, numDigits);
    cudaDeviceSynchronize();

    cudaDeviceSynchronize();
    cudaMemcpy(frequency, de_frequency, 10*sizeof(int), cudaMemcpyDeviceToHost);

    // Print the resulting frequency of digits
    for (int i = 0; i < 10; i++) {
        // Print the digit frequency in the format of digit: count
       printf("%d:\t%d\n", i, frequency[i]);;
    }

    // Clean up
    free(digits);
    free(frequency);
    cudaFree(de_frequency);
    fclose(fp);

    return 0;
}
