#define UART_BASE 0x10000000L
#define UART_TX   0
void _start() {
  *(volatile char *)(UART_BASE + UART_TX) = 'A';
  *(volatile char *)(UART_BASE + UART_TX) = '\n';
  while (1);
}

// riscv64-linux-gnu-gcc -Wno-nonnull-compare -O2 -MMD -Wall -Werror -fno-asynchronous-unwind-tables -fno-builtin -fno-stack-protector -Wno-main -U_FORTIFY_SOURCE -fvisibility=hidden -fno-pic -march=rv64g -mcmodel=medany -mstrict-align -march=rv32e_zicsr -mabi=ilp32e -static -fdata-sections -ffunction-sections uart.c -c -o uart.o
// riscv64-linux-gnu-objdump -d uart.o > uart.txt
// riscv64-linux-gnu-objcopy -S --set-section-flags .bss=alloc,contents -O binary uart.o uart.bin