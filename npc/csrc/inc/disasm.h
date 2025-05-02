#ifndef NPC_DISASM
#define NPC_DISASM

#include <stdint.h>

void init_disasm();

void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

#endif // NPC_DISASM