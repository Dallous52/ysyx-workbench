#include "device.h"

#include <cstdint>
#include <cstdio>

typedef uint64_t (*diff_exec)(uint64_t);
extern diff_exec ref_difftest_exec;


bool cachesim_step(int cache_ls, int block_ls)
{
#ifdef RUNSOC
    word_t pc = 0x30000000;
#else
    word_t pc = 0x80000000;
#endif

    uint64_t ret = ref_difftest_exec(1);
    uint32_t inst = (uint32_t)(ret >> 32);
    pc = (uint32_t)ret;
    
    printf("cachesim:> %08x : [ %08x ]\n", pc, inst);

    return true;
}