#include "device.h"
#include "memory.h"

#include <cstdio>

typedef uint64_t (*diff_sim)();
extern diff_sim ref_difftest_sim;

void nemu_init(long img_size, int port);

bool cachesim_run(int cache_ls, int block_ls)
{
#ifdef RUNSOC
    word_t pc = 0x30000000;
#else
    word_t pc = 0x80000000;
#endif
    
    uint32_t inst = 0;
    while (pc != 0)
    {
        uint64_t ret = ref_difftest_sim();
        inst = (uint32_t)(ret >> 32);
        pc = (uint32_t)ret;
        
        // printf("cachesim:> %08x : [ %08x ]\n", pc, inst);
    }

    nemu_init(get_img_size(), 0);
    
    return true;
}