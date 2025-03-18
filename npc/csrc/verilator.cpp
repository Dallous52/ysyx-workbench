#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <unistd.h>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vtop.h"

int main(int argc, char** argv)
{
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    Vtop* top = new Vtop{contextp};
    
    // 接下来的四行代码用于设置波形存储为VCD文件
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;  
    dut->trace(m_trace, 5);               
    m_trace->open("waveform.vcd");

    // 初始化随机数发生器
    time_t t;
    srand((unsigned) time(&t));

    while (!contextp->gotFinish())
    {
      int a = rand() & 1;
      int b = rand() & 1;
      top->a = a;
      top->b = b;
      top->eval();
      printf("a = %d, b = %d, f = %d\n", a, b, top->f);
      assert(top->f == (a ^ b));
      sleep(1);
    }

    delete top;
    delete contextp;

    return 0;
}
