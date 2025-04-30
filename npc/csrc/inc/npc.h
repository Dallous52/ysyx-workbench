#ifndef NPC_NPC
#define NPC_NPC

#include "tpdef.h"


// initialize npc resource
void npc_init(bool vcd);

// execute npc steps
int cpu_exec(uint64_t steps);

// print regiestor
void reg_print();

// free npc resource
void npc_free();

#endif // NPC_NPC