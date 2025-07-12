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
#define DEV_SPI     (0x10001000)

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


void uart_init()
{
  volatile uint8_t* uart_lcr = (volatile uint8_t*)(DEV_SERIAL + 3);
  *uart_lcr = 0x83;

  volatile uint8_t* uart_divisor = (volatile uint8_t*)DEV_SERIAL;
  uart_divisor[1] = 0x00;
  uart_divisor[0] = 0x46;

  *uart_lcr = 0x03;
}


void spi_init()
{
  volatile uint8_t* spi_ctrl = (volatile uint8_t*)(DEV_SPI + 0x10);
  spi_ctrl[3] = 0x00;
  spi_ctrl[2] = 0x00;
  spi_ctrl[1] = 0x28;
  spi_ctrl[0] = 0x08;
  
  volatile uint8_t* spi_divider = (volatile uint8_t*)(DEV_SPI + 0x14);
  spi_divider[3] = 0;
  spi_divider[2] = 0;
  spi_divider[1] = 0;
  spi_divider[0] = 0x01;

  volatile uint8_t* spi_ss = (volatile uint8_t*)(DEV_SPI + 0x18);
  spi_ss[3] = 0;
  spi_ss[2] = 0;
  spi_ss[1] = 0;
  spi_ss[0] = 0x80;
}


void _trm_init()
{
  bootloader();
  uart_init();
  spi_init();
  int ret = main(mainargs);
  halt(ret);
}
