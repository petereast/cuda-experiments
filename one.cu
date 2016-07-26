#include <iostream>
#include <stdio.h>

void getInfo( void )
{
    cudaDeviceProp p;

    int capability = p.major;

    if(capability)
    {
        cudaGetDeviceProperties( &p, 0);
        printf(" -- Information & Properties about CUDA device 0 -- \n");
        printf("\tCompute Capability: %i.%i\n", p.major, p.minor);
        printf("\tDevice Name: %s\n", p.name);
        printf("\tClock Rate: %d\n", p.clockRate);
        printf("\tGlobal Memory: %dMiB\n", p.totalGlobalMem/(1024*1024));
        printf(" -- End of Information -- \n");
    }else
    {
        printf(" -- Warning: No CUDA Device Detected :'( -- \n");
    }


}

// Let's do a basic CAESAR shift cipher, implemented in CUDA
__global__ void caeasrCipher(char *key, char *text, int tlength, int klength);


int main( void ){

    getInfo();

    char *key = "Hellfo";
    char *text = "The Quick Brown Fox Jumped over The Lazy Dawg";

    char *dev_key, *dev_text;

    cudaMalloc( (void**)&dev_key, strlen(key)*sizeof(char));
    cudaMalloc( (void**)&dev_text, strlen(text)*sizeof(char));

    cudaMemcpy( dev_key, key, strlen(key)*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy( dev_text, text, (strlen(text)+1)*sizeof(char), cudaMemcpyHostToDevice);
    printf("Key: %s(%d)\nText: '%s'(%d)\n", key, strlen(key), text, strlen(text));
    caeasrCipher<<<1024, 1>>>(dev_key, dev_text, strlen(text), strlen(key));

    cudaMemcpy(text, dev_text, (strlen(text)+1)*sizeof(char), cudaMemcpyDeviceToHost);

    printf("Output: %s\n", text);

    cudaFree(dev_text);
    cudaFree(dev_key);


    return 0;
}

__global__ void caeasrCipher(char *key, char *text, int tlength, int klength)
{
    int tid = blockIdx.x;
    if (tid < tlength)
    {
        printf("%c - %d\n",text[tid], tid);
        (char*)text[tid] = ((int)text[tid] + (int)key[tid % klength])%127;
        printf("%c - %d\n",text[tid], tid);
    }

}
