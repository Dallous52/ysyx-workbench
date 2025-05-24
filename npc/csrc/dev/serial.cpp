#include "device.h"

#include <cstdio>

void serial_handler(word_t addr, void* data, bool isw)
{
    int* ch = (int*)data;
    putchar(*ch);
}