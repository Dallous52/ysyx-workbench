#include "tpdef.h"
#include <cstdint>
#include <cstdio>

enum {
    IOPT = 0, IJMP, IMEM, ICSR,
    EEND
};

static const char* type_name[EEND] = {
    "OPT", "JMP", "MEM", "CSR"
};

static int counter[EEND] = { 0 };
static int64_t cycnum[EEND] = { 0 };

extern "C" void monitor_counter(int dtype)
{
    counter[dtype]++;
}


void cycle_counter(word_t inst, int64_t ncyc)
{
    uint8_t opt = BITS(inst, 6, 0);

    switch (opt) 
    {
    case 0b0010011: cycnum[IOPT] += ncyc; break;            
    case 0b0010111: cycnum[IOPT] += ncyc; break;            
    case 0b0110111: cycnum[IOPT] += ncyc; break;            
    case 0b1100111: cycnum[IJMP] += ncyc; break;            
    case 0b1101111: cycnum[IJMP] += ncyc; break;            
    case 0b1110011: cycnum[ICSR] += ncyc; break;            
    case 0b0100011: cycnum[IMEM] += ncyc; break;            
    case 0b0000011: cycnum[IMEM] += ncyc; break;            
    case 0b0110011: cycnum[IOPT] += ncyc; break;            
    case 0b1100011: cycnum[IJMP] += ncyc; break;            
    default: ;
    }
}


void pmc_print()
{
    int64_t all_inst = 0, all_cycle = 0;

    printf(ANSI_FG_BLUE "%-6s\t%10s\t%10s\t%5s\n" ANSI_NONE,
        "type", "inst", "cycle", "cpi");

    for (int i = 0; i < EEND; i++) 
    {
        all_inst += counter[i];
        all_cycle += cycnum[i];
        printf(ANSI_FMT("%-6s\t%10d\t%10ld\t%5ld", ANSI_FG_GREEN) "\n", 
            type_name[i], counter[i], cycnum[i], cycnum[i] / counter[i]);
    }

    printf(ANSI_FMT("%-6s\t%10ld\t%10ld\t%5ld", ANSI_FG_GREEN) "\n", 
        "total", all_inst, all_cycle, all_cycle / all_inst);
}

/*
IFU:     597849
LSU:     736430
!EXU:    0
I-OPT:   318034
I-JUMP:  141231
I-MEM:   138581
I-CSR:   2
*/