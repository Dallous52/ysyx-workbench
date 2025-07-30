#include "device.h"

#include <cstdio>

typedef word_t (*diff_exec)(uint64_t);
extern diff_exec ref_difftest_exec;


bool cachesim_step()
{
#ifdef RUNSOC
    word_t pc = 0x30000000;
#else
    word_t pc = 0x80000000;
#endif

    printf("cachesim:> %08x\n", pc);
    pc = ref_difftest_exec(1);

    return true;
}