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

__attribute__((section("entry"))) void print_hex(uint32_t num) {
    // 每个 16 进制字符代表 4 位，一共 8 个 hex 字符
    for (int i = 7; i >= 0; i--) {
        uint8_t nibble = (num >> (i * 4)) & 0xF;  // 取出每 4 位
        char hex_char;

        if (nibble < 10)
            hex_char = '0' + nibble;
        else
            hex_char = 'A' + (nibble - 10);

        putch(hex_char);
    }
    putch('\n');
}

__attribute__((section("entry"))) void _first_bootloader()
{
    device_ctrl uart_lcr = (device_ctrl)(DEV_SERIAL + 3);
    *uart_lcr = 0x83;

    device_ctrl uart_divisor = (device_ctrl)DEV_SERIAL;
    uart_divisor[1] = 0x00;
    uart_divisor[0] = 0x01;

    *uart_lcr = 0x03;

    uint8_t *d = (uint8_t*)&_ssbl_start;
    const uint8_t *s = (uint8_t*)DEV_SRAM;
    uint32_t n = (uintptr_t)&_ssbl_end - (uintptr_t)&_ssbl_start;

    while (n--) {
        print_hex(n);
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