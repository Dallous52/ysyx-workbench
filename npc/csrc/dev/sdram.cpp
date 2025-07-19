#include "tpdef.h"

#include <cstdint>
#include <cstdio>
#include <cstring>

#include <sys/types.h>
#include <verilated.h>

static uint16_t sdram[4][8192][512] __attribute((aligned(4096))) = {};


word_t sdram_read_expr(word_t addr)
{
    return *((word_t*)((uint8_t*)sdram + addr));
}


extern "C" void sdram_row_load(int8_t bank, int16_t row, int16_t *data)
{
    for (int i = 0; i < 512; i++) data[i] = sdram[bank][row][i];
    printf(ANSI_FMT("[read sdram] bank:%d  row:0x%04x;\n", ANSI_FG_CYAN),
			bank, row);
}


extern "C" void sdram_row_store(int8_t bank, int16_t row, uint16_t data[512])
{
    printf("%04x %04x\n", data[1], data[0]);
    for (int i = 0; i < 512; i++) sdram[bank][row][i] = data[i];
    printf(ANSI_FMT("[write sdram] bank:%d  row:0x%04x;\n", ANSI_FG_CYAN),
			bank, row);
}