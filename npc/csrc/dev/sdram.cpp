#include "tpdef.h"

#include <cstdint>
#include <cstdio>
#include <cstring>

#include <sys/types.h>
#include <svdpi.h>

static uint16_t sdram[4][8192][512][2] __attribute((aligned(4096))) = {};


word_t sdram_read_expr(word_t addr)
{
    addr = addr / 4;
    int bank = (addr / 512) % 4;
    int row = addr / 2048;
    int idx = addr % 512;
    printf(ANSI_FMT("[read sdram] bank:%d  row:0x%04x  idx:%d;  data:%04x %04x\n", ANSI_FG_CYAN),
    		bank, row, idx, sdram[bank][row][idx][1], sdram[bank][row][idx][0]);
    return ((uint32_t)sdram[bank][row][idx][1] << 16) | (uint32_t)sdram[bank][row][idx][0];
}


extern "C" void sdram_row_load(int8_t bank, int16_t row, int16_t *data, int8_t raw)
{
    int n = svSize(data, 1);
    uint16_t *p0 = (uint16_t*)svGetArrayPtr(data);

    for (int i = 0; i < n; i++) p0[i] = sdram[bank][row][i][raw];
 
    // printf(ANSI_FMT("[read sdram] bank:%d  row:0x%04x  num:%d;\n", ANSI_FG_CYAN),
	// 		bank, row, n);
}


extern "C" void sdram_row_store(int8_t bank, int16_t row, const svOpenArrayHandle data, int8_t raw)
{
    int n = svSize(data, 1);
    uint16_t *p0 = (uint16_t*)svGetArrayPtr(data);

    for (int i = 0; i < n; i++) sdram[bank][row][i][raw] = p0[i];

    // printf(ANSI_FMT("[write sdram] bank:%d  row:0x%04x  num:%d;\n", ANSI_FG_CYAN),
	// 		bank, row, n);
}