#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include "../riscv.h"

#include "device/device.h"

extern char _ssbl_load;
extern char _ssbl_op;
extern char _ssbl_ed;

extern char _code_start;
extern char _code_op;
extern char _code_ed;

typedef void (*voidfunc)();

__attribute__((section("entry"))) void _first_bootloader()
{
    uint8_t *d = (uint8_t*)DEV_SRAM;
    const uint8_t *s = (uint8_t*)&_ssbl_load;
    uint32_t n = (uintptr_t)&_ssbl_ed - (uintptr_t)&_ssbl_op;

    while (n--) {
        *d++ = *s++;
    }

    voidfunc ssbl = (voidfunc)(DEV_SRAM);
    ssbl();
}


__attribute__((section("ssbl.boot"))) void _second_bootloader()
{
    uint8_t *d = (uint8_t*)DEV_PSRAM;
    const uint8_t *s = (uint8_t*)&_code_start;
    uint32_t n = (uintptr_t)&_code_ed - (uintptr_t)&_code_op;
    while (n--) {
        *d++ = *s++;
    }

    voidfunc start = (voidfunc)(DEV_PSRAM);
    start();
}