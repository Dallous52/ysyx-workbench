#include "Vysyx_25040111_top___024root.h"
#include "Vysyx_25040111_top.h"
#include "npc.h"
#include "memory.h"
#include "tpdef.h"

#include <cstddef>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>

#define VCD_PATH "/home/dallous/Documents/ysyx-workbench/npc/waveform.vcd"
#define REG ysyx_25040111_top__DOT__u_RegisterFile__DOT__rf

static Vysyx_25040111_top top;
static VerilatedVcdC *vtrace = nullptr;

// 用于计数时钟边沿
static vluint64_t sim_time = 0;

// regiestor name
static const char *regs[] = {
    "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};


// initialize npc resource
void npc_init(bool vcd)
{
    if (vcd)
    {
        // 设置波形存储为VCD文件
        Verilated::traceEverOn(true);
        vtrace = new VerilatedVcdC;
        top.trace(vtrace, 5);
        vtrace->open(VCD_PATH);
    }
    
    top.pc = 0x80000000;
}


// execute
int cpu_exec(uint64_t steps)
{
    while (steps--)
    {
        std::printf("PC = 0x%08x\n", top.pc);
        top.inst = paddr_read(top.pc, 4);
        std::printf("inst = 0x%08x\n", top.inst);
        
        top.clk = 0; top.eval();
        if (vtrace) vtrace->dump(sim_time++);
        top.clk = 1; top.eval();
        if (vtrace) vtrace->dump(sim_time++);
    }

    return steps;
}


// print regiestor
void reg_print()
{
    for (int i = 0; i < ARRLEN(regs); i++)
    {
        printf("[%s]\t0x%08x\n", regs[i], top.rootp->REG[i]);
    }
}


// free npc resource
void npc_free()
{
    if (vtrace)
    {    
        vtrace->close();
        delete vtrace;
    }
}


// inst: ebreak
extern "C" void ebreak(int code)
{
    printf("PC = 0x%08x  ", top.pc);

    if (code)
    {
        printf("[" ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED) "]");
        putchar('\n');
    }
    else 
    {
        printf("[" ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) "]");
        putchar('\n');
    }

    finalize();
}