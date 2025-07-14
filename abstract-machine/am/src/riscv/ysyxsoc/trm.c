#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>
#include "../riscv.h"
#include "device/device.h"

extern char _heap_start;
extern char _heap_end;

extern char _load_start;
extern char _data_end;
extern char _data_start;
void __am_uart_init();
int main(const char *args);

Area heap = RANGE(&_heap_start, &_heap_end);
static const char mainargs[MAINARGS_MAX_LEN] = MAINARGS_PLACEHOLDER; // defined in CFLAGS


void putch(char ch) {
  volatile uint8_t* uart_lsr = (volatile uint8_t*)(DEV_SERIAL + 5);
  while (!(*uart_lsr & 0x20));
  outb(DEV_SERIAL, ch);
}


char getch(){
  return (char)inb(DEV_SERIAL);
}


void halt(int code) 
{
  asm volatile("mv a0, %0; ebreak" : :"r"(code));
  while (1);
}


void bootloader()
{
  memcpy((void*)DEV_SRAM, &_load_start, (&_data_end - &_data_start));
}


void devinfo_print()
{
    unsigned int value;
    asm volatile ("csrr %0, mvendorid" : "=r"(value));
    char* ysyx = (char*)&value;
    putch(ysyx[0]); putch(ysyx[1]); putch(ysyx[2]); putch(ysyx[3]);
    putch('_');
    asm volatile ("csrr %0, marchid" : "=r"(value));
    char id[9] = {}; 
    uint8_t i = 8;
    while (value)
    {
       id[--i] = value % 10;
       value /= 10;
    }
    putstr(id); putch('\n');
}


void _trm_init()
{
  bootloader();
  __am_uart_init();
  devinfo_print();
  int ret = main(mainargs);
  halt(ret);
}
