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
    case 0b0010011: cycnum[IOPT] += ncyc;            
    case 0b0010111: cycnum[IOPT] += ncyc;            
    case 0b0110111: cycnum[IOPT] += ncyc;            
    case 0b1100111: cycnum[IJMP] += ncyc;            
    case 0b1101111: cycnum[IJMP] += ncyc;            
    case 0b1110011: cycnum[ICSR] += ncyc;            
    case 0b0100011: cycnum[IMEM] += ncyc;            
    case 0b0000011: cycnum[IMEM] += ncyc;            
    case 0b0110011: cycnum[IOPT] += ncyc;            
    case 0b1100011: cycnum[IJMP] += ncyc;            
    default: ;
    }
}


void pmc_print()
{
    int64_t all_inst = 0, all_cycle = 0;

    printf(ANSI_FG_BLUE "type\tinst\tcycle\tcpi\n" ANSI_NONE);
    for (int i = 0; i < EEND; i++)
    {
        all_inst += counter[i];
        all_cycle += cycnum[i];
        printf(ANSI_FMT("%s\t%d\t%ld\t%ld", ANSI_FG_BLUE) "\n", 
            type_name[i], counter[i], cycnum[i], cycnum[i] / counter[i]);
    }
    printf(ANSI_FMT("total\t%ld\t%ld\t%ld", ANSI_FG_BLUE) "\n", 
        all_inst, all_cycle, all_cycle / all_inst);
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