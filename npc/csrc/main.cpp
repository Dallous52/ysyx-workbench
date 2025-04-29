#include "Vysyx_25040111_top.h"
#include "memory.h"

#include <cstdio>
#include <iostream>
#include <verilated.h>

#ifdef VCD_F
#include <verilated_vcd_c.h>
#endif // VCD_F

bool initialize(int argc, char** argv);

Vysyx_25040111_top top;

int main(int argc, char** argv)
{
#ifdef VCD_F
    // 接下来的四行代码用于设置波形存储为VCD文件
    Verilated::traceEverOn(true);
    VerilatedVcdC *vtrace = new VerilatedVcdC;
    top->trace(vtrace, 5);
    vtrace->open("waveform.vcd");
    vluint64_t sim_time = 0; // 用于计数时钟边沿
#endif // VCD_F

    initialize(argc, argv);

    top.pc = 0x80000000;
    // char c = 's';
    while (true)
    { 
        std::printf("PC = 0x%08x\n", top.pc);
        top.inst = paddr_read(top.pc, 4);
        std::printf("inst = 0x%08x\n", top.inst);
        
        top.clk = 0; top.eval();
#ifdef VCD_F
        vtrace->dump(sim_time++);
#endif // VCD_F
        top.clk = 1; top.eval();
#ifdef VCD_F
        vtrace->dump(sim_time++);
#endif // VCD_F
        // std::cin >> c;
    }

#ifdef VCD_F
    vtrace->close();
#endif // VCD_F

    return 0;
}


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
    exit(0);
}