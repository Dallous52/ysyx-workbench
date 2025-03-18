#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <unistd.h>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vtop.h"

#define MAX_SIM_TIME 20  // 仿真总时钟边沿数
vluint64_t sim_time = 0; // 用于计数时钟边沿

int main(int argc, char** argv)
{
    Vtop* top = new Vtop;

    // 接下来的四行代码用于设置波形存储为VCD文件
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;  
    top->trace(m_trace, 5);               
    m_trace->open("waveform.vcd");

    // 初始化随机数发生器
    time_t t;
    srand((unsigned) time(&t));

    while (sim_time < MAX_SIM_TIME)
    {
      int a = rand() & 1;
      int b = rand() & 1;
      top->a = a;
      top->b = b;
      top->eval();
      printf("a = %d, b = %d, f = %d\n", a, b, top->f);
      assert(top->f == (a ^ b));
      m_trace->dump(sim_time);
      sim_time++; // 更新仿真时间
    }

    delete top;

    return 0;
}
