#include "tpdef.h"

#include <cstdint>
#include <cstdio>
#include <cstring>

#include <svdpi.h>

static uint16_t sdram[4][8192][512] __attribute((aligned(4096))) = {};


word_t sdram_read_expr(word_t addr)
{
    return *((word_t*)((uint8_t*)sdram + addr));
}


extern "C" void sdram_row_load(int8_t bank, int16_t row, int16_t *data)
{
    int n = svSize(data, 1);
    uint16_t *p0 = (uint16_t*)svGetArrayPtr(data);

    for (int i = 0; i < n; i++) p0[i] = sdram[bank][row][i];

    // printf(ANSI_FMT("[read sdram] bank:%d  row:0x%04x  num:%d;", ANSI_FG_CYAN "\r"),
	// 		bank, row, n);
}


extern "C" void sdram_row_store(int8_t bank, int16_t row, const svOpenArrayHandle data)
{
    int n = svSize(data, 1);
    uint16_t *p0 = (uint16_t*)svGetArrayPtr(data);

    for (int i = 0; i < n; i++) sdram[bank][row][i] = p0[i];

    // printf("\n" ANSI_FMT("[write sdram] bank:%d  row:0x%04x  num:%d;", ANSI_FG_CYAN) "\r",
	// 		bank, row, n);
}