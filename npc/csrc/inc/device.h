#ifndef NPC_DEVICE
#define NPC_DEVICE

#include "tpdef.h"

#define DEV_SERIAL 0xa00003f8
#define DEV_TIMER  0xa0000048


void device_init();

bool device_call(uint32_t addr, void* data, bool isw);

#endif