#include "tpdef.h"
#include <cstdio>

enum {
    IFU = 0, LSU, EXU,
    IOPT, IJUMP, IMEM, ICSR, ISTORE, ILOAD,
    EEND
};

static const char* type_name[EEND] = {
    "IFU", "LSU", "!EXU", 
    "I-OPT", "I-JUMP", "I-MEM", "I-CSR", "I-STORE", "I-LOAD"
};

static int counter[EEND] = { 0 };


extern "C" void monitor_counter(int dtype)
{
    counter[dtype]++;
}


void pmc_print()
{
    for (int i = 0; i < EEND; i++)
    {
        printf(ANSI_FMT("%s:\t %d", ANSI_BG_BLUE) "\n", 
            type_name[i], counter[i]);
    }
}