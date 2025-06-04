#include "device.h"
#include "tpdef.h"

#include <cstdio>

typedef  void (*callback)(word_t, void*, bool);

typedef struct 
{
    uint32_t start;
    uint32_t end;
    callback handler;

} map;


static map mmio_map[16];
static int mmio_idx = 0;

// add new device
static void device_add(uint32_t addr, uint32_t len, callback handler)
{
    mmio_map[mmio_idx].start = addr;
    mmio_map[mmio_idx].end = addr + len - 1;
    mmio_map[mmio_idx].handler = handler;
    mmio_idx++;
}


// device call back function
void serial_handler(word_t addr, void* data, bool isw);
void timer_handler(word_t addr, void* data, bool isw);

// device init0
void timer_init();

// init all device
void device_init()
{
    timer_init();

    device_add(DEV_SERIAL, 1, serial_handler);
    device_add(DEV_TIMER,  8, timer_handler);
}


// mmio mapping : call device
bool device_call(uint32_t addr, void *data, bool isw)
{
    for (int i = 0; i < mmio_idx; i++)
    {
        if (mmio_map[i].start <= addr && mmio_map[i].end >= addr)
        {
            mmio_map[i].handler(addr, data, isw);
            return true;
        }
    }

    printf(ANSI_FMT("device address not found 0x%08x\n", ANSI_FG_RED), addr);
    void pc_print();
    pc_print();
    return false;
}