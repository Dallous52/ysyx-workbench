#include <cstdio>

void serial_handler(void* data)
{
    int* ch = (int*)data;
    putchar(*ch);
}