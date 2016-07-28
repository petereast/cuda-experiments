// This turned out to be a little more complex than I had first thought, maybe I should try a different project.
//


#include <iostream>
#include <stdio.h>


void getInfo( void );
bool getDevicePresent( void );

// Let's do a basic CAESAR shift cipher, implemented in CUDA
__global__ void caesarCipher(char *key, char *text, int tlength, int klength);
__global__ void unCaesarCipher(char *key, char *text, int tlength, int klength);


int main( void ){

    getInfo();

    if(!getDevicePresent())
    {
        return -1;
    }

    char *key = "fsdbikjb";
    char *text = "The Quick Brown Fox Jumped over The Lazy Dawg";

    char *dev_key, *dev_text;

    int textSize =(strlen(text) * sizeof(char))+1;
    int keySize = (strlen(key) * sizeof(char))+1;

    cudaMalloc( (void**)&dev_key, textSize);
    cudaMalloc( (void**)&dev_text, textSize);

    cudaMemcpy( dev_key, key, keySize, cudaMemcpyHostToDevice);
    cudaMemcpy( dev_text, text, textSize, cudaMemcpyHostToDevice);

    //printf("%i %i %i\n", (int)sizeof(text), (strlen(text)+1)*sizeof(char), (strlen(text))*sizeof(char));

    printf("Key: %s(%d)\nText: '%s'(%d)\n", key, keySize, text,textSize);
    caesarCipher<<<textSize, 1>>>(dev_key, dev_text, textSize, keySize);


    char * result = (char *)malloc(textSize);
    cudaMemcpy(result, dev_text, textSize, cudaMemcpyDeviceToHost);

    printf("Output:");
    printf(" '%s'\n", result);
    printf("Length: %i", strlen(result));

    unCaesarCipher<<<textSize, 1>>>(dev_key, dev_text, textSize, keySize);

    cudaMemcpy(result, dev_text, textSize, cudaMemcpyDeviceToHost);

    printf("Output:");
    printf(" '%s'\n", result);
    printf("Length: %i", strlen(result));


    printf("Clearing Memory...\n");

    cudaFree(dev_text);
    cudaFree(dev_key);
    free(result);


    return 0;
}

__global__ void caesarCipher(char *key, char *text, int tlength, int klength)
{
    int tid = blockIdx.x;
    if (tid < tlength)
    {
        //printf("%i says - %s\n", tid, text);
        char t = text[tid];
        text[tid] = ((int)text[tid] + (int)key[tid % klength])%127;
        printf("%c -> %c - %d\n",t,text[tid], tid);
    }

}

__global__ void unCaesarCipher(char *key, char *text, int tlength, int klength)
{
    int tid = blockIdx.x;
    if (tid < tlength)
    {
        //printf("%i says - %s\n", tid, text);
        char t = text[tid];
        text[tid] = ((int)text[tid] - (int)key[tid % klength])%127;
        printf("%c -> %c - %d\n",t,text[tid], tid);
    }

}

void getInfo( void )
{
    cudaDeviceProp p;

    if(getDevicePresent())
    {
        cudaGetDeviceProperties( &p, 0);
        printf(" -- Information & Properties about CUDA device 0 -- \n\n");
        printf("\tCompute Capability: %i.%i\n", p.major, p.minor);
        printf("\tDevice Name: %s\n", p.name);
        printf("\tClock Rate: %d\n", p.clockRate);
        printf("\tGlobal Memory: %dMiB\n", p.totalGlobalMem/(1024*1024));
        printf("\n -- End of Information -- \n");
    }else
    {
        printf(" -- Warning: No CUDA Device Detected :'( -- \n");
        printf(" -- This software might not operate as   -- \n -- Expected.                            -- \n");
    }
}

bool getDevicePresent( void )
{
    cudaDeviceProp p;
    cudaGetDeviceProperties( &p, 0);
    return (p.major != 0);
}
