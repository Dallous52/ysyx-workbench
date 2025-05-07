#ifndef NPC_DISASM
#define NPC_DISASM

#include <stdint.h>

enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

// initialize disassemble
void init_disasm();

// disassemble
void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

// initialize ftrace elf struct
bool init_elf(const char* elf_file);

// initialize DiffTest
void init_difftest(long img_size, int port);

// difftest step
void difftest_step(uint32_t pc);

#endif // NPC_DISASM