#include "device.h"
#include "memory.h"
#include "tpdef.h"

#include <cstdint>
#include <cstdio>
#include <string.h>
#include <math.h>

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
    
    int block_l = (int)pow(2, block_ls) * 8;
    int cache_l = (int)pow(2, cache_ls);

    uint32_t* tags = new uint32_t[cache_l];
    bool* valids = new bool[cache_l];
    memset(valids, 0, sizeof(bool) * cache_l);

    int tag_idx = block_ls + cache_ls;

    double inst = 0, hitnum = 0;
    while (pc != 0)
    {
        uint32_t tag = BITS(pc, 31, tag_idx);
        uint32_t index = BITS(pc, tag_idx - 1, block_ls);
        uint32_t offset = BITS(pc, block_ls - 1, 0);
        
        bool hit = (tags[index] == tag) && valids[index];
        if (hit) hitnum++;
        else
        {
            tags[index] = tag;
            valids[index] = true;
        }

        uint64_t ret = ref_difftest_sim();
        pc = (uint32_t)ret;
        inst++;
    }

    double p = hitnum / inst;
    printf("[cache hit] = " ANSI_FMT("%ld / %ld", ANSI_FG_GREEN) "\n", (long)inst, (long)hitnum);
    printf(" [hit rate] = " ANSI_FMT("%5.3lf%%", ANSI_FG_GREEN) "\n", p * 100.);
    printf("     [AMAT] = " ANSI_FMT("%5.3lf", ANSI_FG_GREEN) "\n", 3. + (1. - p) * 8);

    nemu_init(get_img_size(), 0);
    
    return true;
}