#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stddef.h>
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
  // if ((uintptr_t)&_load_start == 0X200001dc) halt(1);
  size_t wsize = &_data_end - &_data_start;
  if (wsize == 50) halt(1);
  memcpy((void*)DEV_SRAM, &_load_start, wsize);
}


void _trm_init() {
  bootloader();
  int ret = main(mainargs);
  halt(ret);
}
