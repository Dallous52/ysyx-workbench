#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vtop.h"

// 双控开关模块
#ifdef DUALCTL_M
#define MAX_SIM_TIME 50  // 仿真总时钟边沿数
vluint64_t sim_time = 0; // 用于计数时钟边沿

void verilator_main_loop(Vtop* top, VerilatedVcdC* vtrace)
{
    // 初始化随机数发生器
    time_t t;
    srand((unsigned) time(&t));
    top->ledr = 0;

    while (sim_time < MAX_SIM_TIME)
    {
        top->sw = (unsigned char)rand() % 4;
        top->eval();
        printf("sw = %d, f = %d\n", top->sw, top->ledr);
        vtrace->dump(sim_time);
        sim_time++; // 更新仿真时间
    }
}
#endif // DUALCTL_M