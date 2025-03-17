#include "Vtop.h"
#include "verilated.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char** argv)
{
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    Vtop* top = new Vtop{contextp};

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
