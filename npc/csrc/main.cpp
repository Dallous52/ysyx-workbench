#include "Vysyx_25040111_top.h"

#include <verilated.h>
#ifdef VCD_F
#include <verilated_vcd_c.h>
#endif // VCD_F

int main(int argc, char** argv)
{
    Vysyx_25040111_top* top = new Vysyx_25040111_top();

#ifdef VCD_F
    // 接下来的四行代码用于设置波形存储为VCD文件
    Verilated::traceEverOn(true);
    VerilatedVcdC *vtrace = new VerilatedVcdC;
    top->trace(vtrace, 5);
    vtrace->open("waveform.vcd");
    vluint64_t sim_time = 0; // 用于计数时钟边沿
#endif // VCD_F

    while (true)
    {
        top->inst = 0xffc10113;
        top->eval();
#ifdef VCD_F
        vtrace->dump(sim_time++);
#endif // VCD_F
    }

#ifdef VCD_F
    vtrace->close();
#endif // VCD_F

    delete top;

    return 0;
}