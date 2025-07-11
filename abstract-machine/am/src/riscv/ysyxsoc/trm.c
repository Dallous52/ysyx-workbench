#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include "../riscv.h"

extern char _heap_start;
extern char _heap_end;

extern uint8_t _data_load_start[];
extern uint8_t _data_start[];
extern uint8_t _data_end[];

extern uint8_t _bss_start[];
extern uint8_t _bss_end[];

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
  // 拷贝 .data 段内容，从 ROM 到 RAM
  size_t data_size = _data_end - _data_start;
  memcpy((void*)DEV_SRAM, _data_load_start, data_size);

  // 清零 .bss 段
  size_t bss_size = _bss_end - _bss_start;
  for (size_t i = 0; i < bss_size; i++) {
      _bss_start[i] = 0;
  }
}


void _trm_init() {
  bootloader();
  int ret = main(mainargs);
  halt(ret);
}
