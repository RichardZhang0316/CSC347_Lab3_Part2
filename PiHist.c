/**
 * This program implements a serial code via a function call that computes the distribution of the digits of Pi
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
#define MaxNumberOfDigits 10000000


void computeAndPrintFrequency(int frequency[], int count, FILE *fp, int numDigits) {
    int character;
    while ((character = fgetc(fp)) != EOF && count < numDigits) {
        if (isdigit(character)) {
            frequency[character - '0']++;
            count++;
        }
    }

    for (int i = 0; i < 10; i++) {
        // print the digit frequency in the format of digit: frequency (in percentage)
        printf("%d:\t%f%%\n", i, (double)frequency[i]/count*100);
    }
}

int main(int argc, char *argv[]) {
    // Determine if there are two arguments on the command line
    if (argc != 3) {
        printf("Command line arguments are not enough: %s \n", argv[0]);
        return 1;
    }

    // Convert the third argument to integer
    int numDigits = atoi(argv[2]);

    // Determine if the number of digits entered by users is legitamate
    if (numDigits <= 0) {
        printf("Number of digits should not less than 1\n");
        return 2;
    }

    // Check if we can open the file. If not, return error message
    FILE *fp;
    fp = fopen(argv[1], "r");
    if (fp == NULL) {
        printf("%s could not be opened\n", argv[1]);
        return 3;
    }

    // Check if the number of digits entered by the user is more than the number of digits in the file
    if (numDigits > MaxNumberOfDigits) {
        printf("Number of digits cannot be greater than the number of digits in the file %d.\n", MaxNumberOfDigits);
        return 4;
    }

    // initialize the frequency array
    int frequency[10] = {0};
    int count = 0;

    // read the input file and update the frequency array. Then print the frequency
    computeAndPrintFrequency(frequency, count, fp, numDigits);

    // close the file
    fclose(fp);

    return 0;
}
