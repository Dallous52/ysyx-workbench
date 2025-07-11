#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include "../riscv.h"

extern char _heap_start;
extern char _heap_end;

extern char _load_start;
extern char _load_end;

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
  if (&_load_start == &_load_end) halt(1);
  memcpy((void*)DEV_SRAM, &_load_start, &_load_end - &_load_start);
}


void _trm_init() {
  bootloader();
  int ret = main(mainargs);
  halt(ret);
}
