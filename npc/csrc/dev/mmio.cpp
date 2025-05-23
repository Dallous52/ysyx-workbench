#include "device.h"

typedef struct 
{
    uint32_t start;
    uint32_t end;
    voidfunc callback;

} map;


static map mmio_map[16];
static int mmio_idx = 0;

// add new device
static void device_add(uint32_t addr, uint32_t len, voidfunc callback)
{
    mmio_map[mmio_idx].start = addr;
    mmio_map[mmio_idx].end = addr + len - 1;
    mmio_map[mmio_idx].callback = callback;
    mmio_idx++;
}


// device call back function
void serial_handler(void* data);
void timer_handler(void* data);

// device init
void timer_init();

// init all device
void device_init()
{
    timer_init();

    device_add(DEV_SERIAL, 8, serial_handler);
    device_add(DEV_TIMER,  8, timer_handler);
}


// mmio mapping : call device
bool device_call(uint32_t addr, void *data, bool isw)
{
    for (int i = 0; i < mmio_idx; i++)
    {
        if (mmio_map[i].start <= addr && mmio_map[i].end >= addr)
        {
            mmio_map[i].callback(data);
            return true;
        }
    }

    return false;
}