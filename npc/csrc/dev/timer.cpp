#include <stdio.h>
#include <time.h>

struct timespec start, end;

void timer_init()
{
    // 获取程序启动时间
    clock_gettime(CLOCK_MONOTONIC, &start);  
}

void timer_handler(void* data)
{
    clock_gettime(CLOCK_MONOTONIC, &end);    // 当前时间

    long seconds = end.tv_sec - start.tv_sec;
    long nanos = end.tv_nsec - start.tv_nsec;
    
    if (nanos < 0) {
        seconds -= 1;
        nanos += 1000000000;  // 借一秒，补纳秒
    }
    
    (*(long*)data) = seconds * 1000000 + nanos / 1000;
}