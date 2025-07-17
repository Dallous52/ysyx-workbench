#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#include "device/device.h"

extern char _ssbl_start;
extern char _ssbl_end;

extern char _code_start;
extern char _code_end;

typedef void (*voidfunc)();


void _first_bootloader()
{
    memcpy((void*)DEV_SRAM, &_ssbl_start, (&_ssbl_end - &_ssbl_start));
    voidfunc ssbl = (voidfunc)(DEV_SRAM);
    ssbl();
}


void _second_bootloader()
{
    memcpy((void*)DEV_PSRAM, &_code_start, (&_code_end - &_code_start));
    voidfunc start = (voidfunc)(DEV_PSRAM);
    start();
}