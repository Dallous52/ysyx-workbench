#include "tpdef.h"

#include <cstdint>
#include <cstdio>
#include <cstring>

static uint8_t psram[4*1024*1024]  __attribute((aligned(4096))) = {};

extern "C" void psram_read(int32_t addr, int32_t *data)
{
    memcpy(data, psram + addr, 4);
    printf(ANSI_FMT("[read psram] address: 0x%08x; data: 0x%08x;\n", ANSI_FG_CYAN),
			(paddr_t)addr, *data);
}


extern "C" void psram_write(int32_t addr, int32_t data, int32_t len)
{
    uint32_t right = 24;
    uint32_t address = addr;
    while (len--)
    {
        psram[address++] = data >> right;
        right -= 8;         
    }

    printf(ANSI_FMT("[write psram] address: 0x%08x; data: 0x%08x;\n", ANSI_FG_CYAN),
        (paddr_t)addr, data);
}