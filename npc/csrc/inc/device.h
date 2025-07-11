#ifndef NPC_DEVICE
#define NPC_DEVICE

#include "tpdef.h"

#define DEV_SERIAL (0xa00003f8)
#define DEV_TIMER  (0xa0000048)

#define MROM_START  (0x20000000)
#define MROM_END    (0x20000fff)

#define SRAM_START  (0xf000000)
#define SRAM_END    (0xf001fff)

void device_init();

bool device_call(uint32_t addr, void* data, bool isw);

bool device_visit(paddr_t addr);

#endif