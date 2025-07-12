#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>
#include "../riscv.h"

extern char _heap_start;
extern char _heap_end;

extern char _load_start;
extern char _data_end;
extern char _data_start;

int main(const char *args);

#define DEV_SERIAL  (0x10000000)
#define DEV_SRAM    (0x0f000000)

Area heap = RANGE(&_heap_start, &_heap_end);
static const char mainargs[MAINARGS_MAX_LEN] = MAINARGS_PLACEHOLDER; // defined in CFLAGS


void putch(char ch) {
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


void uart_init()
{
  uint8_t* uart_lcr = (uint8_t*)(DEV_SERIAL + 3);
  *uart_lcr = 0b10000011;

  uint16_t* uart_divisor = (uint16_t*)DEV_SERIAL;
  *uart_divisor = 326;

  *uart_lcr = 0b00000011;
}


void _trm_init() 
{
  bootloader();
  uart_init();
  int ret = main(mainargs);
  halt(ret);
}
