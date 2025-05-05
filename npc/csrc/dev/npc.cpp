#include "util.h"
#include "Vysyx_25040111_top___024root.h"
#include "Vysyx_25040111_top.h"
#include "npc.h"
#include "memory.h"
#include "tpdef.h"

#include <cstdint>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>

#define VCD_PATH "/home/dallous/Documents/ysyx-workbench/npc/waveform.vcd"
#define REG top.rootp->ysyx_25040111_top__DOT__u_RegisterFile__DOT__rf

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

uint32_t npc_stat = -1;

// initialize npc resource
void npc_init(bool vcd)
{
    if (vcd)
    {
        // set vcd
        Verilated::traceEverOn(true);
        vtrace = new VerilatedVcdC;
        top.trace(vtrace, 5);
        vtrace->open(VCD_PATH);
    }
    
    top.pc = 0x80000000;
}


static void ftrace(paddr_t pc, paddr_t call, int rd)
{
  const char* ftrace_get_name(paddr_t addr);

  const char* dst = ftrace_get_name(call);
  const char* src = ftrace_get_name(pc);

  if (rd == 1)
  {
    printf("[0x%x in %s] call [%s 0x%x]\n", pc, src, dst, call);
  }
  else if (rd == 0)
  {
    printf("[0x%x in %s] ret  [%s 0x%x]\n", pc, src, dst, call);
  }
}


// print execute infomation
static void print_exe_info(uint32_t pc)
{
    char logbuf[128] = {};
    char* p = logbuf;
    p += snprintf(p, sizeof(logbuf), "0x%08x: ", pc);

    uint8_t *inst = (uint8_t *)&top.inst;
    for (int i = 3; i >= 0; i--) 
        p += snprintf(p, 4, " %02x", inst[i]);

    *p = '\t'; p++;

    disassemble(p, logbuf + sizeof(logbuf) - p, pc, (uint8_t *)&top.inst, 4);
    
    static uint8_t jal = 0b1101111;
    static uint8_t jalr = 0b1100111;
    uint8_t opt = BITS(top.inst, 6, 0);
    uint8_t rd = BITS(top.inst, 11, 7);
    
    if (opt == jal || opt == jalr)
        ftrace(pc, top.pc, rd);
    
    std::cout << logbuf << std::endl;
}


// execute
int cpu_exec(uint64_t steps)
{
    npc_stat = NPC_RUN;

    uint64_t step_ok = 0;
    uint32_t oldpc = 0;

    while (steps--)
    {
        oldpc = top.pc;
        top.inst = paddr_read(top.pc, 4);
        top.clk = 0; top.eval();
        if (vtrace) vtrace->dump(sim_time++);
        top.clk = 1; top.eval();
        if (vtrace) vtrace->dump(sim_time++);

        void check_wp();
        check_wp();

        switch (npc_stat)
        {
        case NPC_EXIT:
            finalize(); break; 
        case NPC_RUN:
            print_exe_info(oldpc); step_ok++; break;
        case NPC_STOP:
            return step_ok;
        case NPC_ABORT:
            finalize(); break;
        }
    }

    return step_ok;
}


// print regiestor
void reg_print()
{
    for (int i = 0; i < ARRLEN(regs); ++i)
    {
        int j = i + 4;
        for (; i < j; ++i)
            printf("[%s]\t0x%08x\t", regs[i], REG[i]);
        putchar('\n');
        --i;
    }
}


// get regiestor value
word_t reg_get_value(char* s, bool* success)
{
    if (s == NULL || success == NULL) 
    {
        if (success == NULL) return 0;

        *success = false;
        return 0;
    }

    if (strcmp(s, "pc") == 0)
    {
        *success = true;
        return top.pc;
    }

    int i = 0;
    for (; i < ARRLEN(regs); i++)
    {
        if (strcmp(s, regs[i]) == 0)
        break;
    }

    if (i == ARRLEN(regs))
    {
        *success = false;
        return 0;
    }

    *success = true;
    return REG[i];
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