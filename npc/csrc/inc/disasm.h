#ifndef NPC_DISASM
#define NPC_DISASM

#include <stdint.h>

// 初始化反汇编器
void init_disasm();

// 反汇编
void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

#endif // NPC_DISASM