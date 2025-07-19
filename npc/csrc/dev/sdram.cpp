#include "tpdef.h"

#include <cstdint>
#include <cstdio>
#include <cstring>

#include <sys/types.h>
#include <verilated.h>

static uint16_t sdram[4][8192][512] __attribute((aligned(4096))) = {};


word_t sdram_read_expr(word_t addr)
{
    return *((word_t*)(sdram + addr));
}


extern "C" void sdram_row_load(int8_t bank, int16_t row, int16_t *data)
{
    memcpy(data, &sdram[bank][row][0], 512 * sizeof(uint16_t));
    printf(ANSI_FMT("[read sdram] bank:%d  row:0x%04x;\n", ANSI_FG_CYAN),
			bank, row);
}


extern "C" void sdram_row_store(int8_t bank, int16_t row, int16_t *data)
{
    memcpy(&sdram[bank][row][0], data, 512 * sizeof(uint16_t));
    printf(ANSI_FMT("[write sdram] bank:%d  row:0x%04x;\n", ANSI_FG_CYAN),
			bank, row);
}