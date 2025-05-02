#ifndef NPC_NPC
#define NPC_NPC

#include "tpdef.h"


// initialize npc resource
void npc_init(bool vcd);

// execute npc steps
int cpu_exec(uint64_t steps);

// print regiestor
void reg_print();

// get regiestor value
word_t reg_get_value(char* s, bool* success);

// free npc resource
void npc_free();

// runtime status
extern uint32_t npc_stat;

#define NPC_EXIT    0
#define NPC_RUN     1
#define NPC_ABORT   2 

#endif // NPC_NPC