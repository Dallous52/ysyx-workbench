#include "tpdef.h"
#include <cstdio>

enum {
    IOPT = 0, IJUMP, IMEM, ICSR,
    EEND
};

static const char* type_name[EEND] = {
    "I-OPT", "I-JUMP", "I-MEM", "I-CSR"
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
        printf(ANSI_FMT("%s:\t %d", ANSI_FG_BLUE) "\n", 
            type_name[i], counter[i]);
    }
}