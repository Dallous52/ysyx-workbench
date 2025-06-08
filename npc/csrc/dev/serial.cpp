#include "device.h"

#include <cstdio>
#include <iostream>

void serial_handler(word_t addr, void* data, bool isw)
{
    if (isw)
    {
        int* ch = (int*)data;
        putchar(*ch);
        fflush(stdout);
    }
    else 
    {
        *((char*)data) = getchar();
        printf("0x%08x\n", addr);
    }
}