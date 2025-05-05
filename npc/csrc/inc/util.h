#ifndef NPC_DISASM
#define NPC_DISASM

#include <stdint.h>

// initialize disassemble
void init_disasm();

// disassemble
void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

// initialize ftrace elf struct
bool init_elf(const char* elf_file);

#endif // NPC_DISASM