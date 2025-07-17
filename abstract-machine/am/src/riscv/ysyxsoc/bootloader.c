#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#include "device/device.h"

extern char _ssbl_start;
extern char _ssbl_end;

extern char _code_start;
extern char _code_end;

typedef void (*voidfunc)();


__attribute__((section("entry"))) void _first_bootloader()
{
    uint8_t *d = (uint8_t*)&_ssbl_start;
    const uint8_t *s = (uint8_t*)DEV_SRAM;
    uint32_t n = (uintptr_t)&_ssbl_end - (uintptr_t)&_ssbl_start;

    while (n--) {
        *d++ = *s++;
    }

    voidfunc ssbl = (voidfunc)(DEV_SRAM);
    ssbl();
}


__attribute__((section("ssbl"))) void _second_bootloader()
{
    uint8_t *d = (uint8_t*)&_code_start;
    const uint8_t *s = (uint8_t*)DEV_PSRAM;
    uint32_t n = (uintptr_t)&_code_end - (uintptr_t)&_code_start;

    while (n--) {
        *d++ = *s++;
    }
    
    voidfunc start = (voidfunc)(DEV_PSRAM);
    start();
}