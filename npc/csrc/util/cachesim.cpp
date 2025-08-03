#include "device.h"
#include "memory.h"
#include "tpdef.h"

#include <cstdio>
#include <string.h>
#include <math.h>

typedef uint64_t (*diff_sim)(word_t*);
extern diff_sim ref_difftest_sim;

static const uint8_t load = 0b0000011;
static const uint8_t store = 0b0100011;

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

    double inst_num = 0, hitnum = 0;
    word_t paddr = 0, inst = 0;;
    while (pc != 0)
    {
        uint32_t tag = BITS(pc, 31, tag_idx);
        uint32_t index = BITS(pc, tag_idx - 1, block_ls);
        
        bool hit = (tags[index] == tag) && valids[index];
        if (hit) hitnum++;
        else
        {
            tags[index] = tag;
            valids[index] = true;
        }

        uint64_t ret = ref_difftest_sim(&paddr);
        pc = (uint32_t)ret;
        inst = (word_t)(ret >> 32);

        uint8_t opcode = BITS(inst, 6, 0);
        if (opcode == load || opcode == store)
        {
            printf("inst:%08x  addr:%08x\n", inst, paddr);
        }

        inst_num++;
    }

    double p = hitnum / inst_num;
    printf("[cache hit] = " ANSI_FMT("%ld / %ld", ANSI_FG_GREEN) "\n", (long)hitnum, (long)inst_num);
    printf(" [hit rate] = " ANSI_FMT("%5.3lf%%", ANSI_FG_GREEN) "\n", p * 100.);
    printf("     [AMAT] = " ANSI_FMT("%5.3lf", ANSI_FG_GREEN) "\n", 3. + (1. - p) * 8);

    nemu_init(get_img_size(), 0);
    
    return true;
}