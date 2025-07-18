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

extern char _rodata_start;
extern char _rodata_op;
extern char _rodata_ed;

extern char _data_start;
extern char _data_op;
extern char _data_ed;

typedef void (*voidfunc)();

__attribute__((section("ssbl"))) void putch_(char ch) {
  volatile uint8_t* uart_lsr = (volatile uint8_t*)(DEV_SERIAL + 5);
  while (!(*uart_lsr & 0x20));
  outb(DEV_SERIAL, ch);
}


// __attribute__((section("ssbl"))) void print_hex_(uint32_t num) {
//     // 每个 16 进制字符代表 4 位，一共 8 个 hex 字符
//     for (int i = 7; i >= 0; i--) {
//         uint8_t nibble = (num >> (i * 4)) & 0xF;  // 取出每 4 位
//         char hex_char;

//         if (nibble < 10)
//             hex_char = '0' + nibble;
//         else
//             hex_char = 'A' + (nibble - 10);

//         putch_(hex_char);
//     }
//     putch_('\n');
// }

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
    device_ctrl uart_lcr = (device_ctrl)(DEV_SERIAL + 3);
    *uart_lcr = 0x83;

    device_ctrl uart_divisor = (device_ctrl)DEV_SERIAL;
    uart_divisor[1] = 0x00;
    uart_divisor[0] = 0x01;

    *uart_lcr = 0x03;
    
    // 代码加载
    uint8_t *d = (uint8_t*)&_code_op;
    const uint8_t *s = (uint8_t*)&_code_start;
    uint32_t n = (uintptr_t)&_code_ed - (uintptr_t)&_code_op;
    while (n--) {
        *d++ = *s++;
    }

    // 只读全局变量加载
    d = (uint8_t*)&_rodata_op;
    s = (uint8_t*)&_rodata_start;
    n = (uintptr_t)&_rodata_ed - (uintptr_t)&_rodata_op;
    while (n--) {
        *d++ = *s++;
    }

    // 全局变量加载
    d = (uint8_t*)&_data_op;
    s = (uint8_t*)&_data_start;
    n = (uintptr_t)&_data_ed - (uintptr_t)&_data_op;
    while (n--) {
        *d++ = *s++;
    }

    voidfunc start = (voidfunc)(&_code_op);
    char notice[] = "bootloader success, call to program.";
    char* put = notice;
    while (*put)
    {
        putch_(*put);
        put++;
    } 
    start();
}