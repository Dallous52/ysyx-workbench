// #include "Vtop.h"
// #include "verilated.h"

// #include <stdio.h>
// #include <stdlib.h>
// #include <assert.h>
// #include <time.h>
// #include <unistd.h>

// int main(int argc, char** argv) 
// {
//     VerilatedContext* contextp = new VerilatedContext;
//     contextp->commandArgs(argc, argv);

//     Vtop* top = new Vtop{contextp};

//     // 初始化随机数发生器
//     time_t t;
//     srand((unsigned) time(&t));

//     while (!contextp->gotFinish())
//     {
//       int a = rand() & 1;
//       int b = rand() & 1;
//       top->a = a;
//       top->b = b;
//       top->eval();
//       printf("a = %d, b = %d, f = %d\n", a, b, top->f);
//       assert(top->f == (a ^ b));
//       sleep(1);
//     }

//     delete top;
//     delete contextp;

//     return 0;
// }

#include <nvboard.h>

#include "Vtop.h"

static void single_cycle(Vtop* dut) 
{
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

static void reset(Vtop* dut, int n) 
{
  dut.rst = 1;
  while (n-- > 0) single_cycle(dut);
  dut.rst = 0;
}

int main()
{
  Vtop* top = new Vtop();

	nvboard_bind_pin(&top->a, 1, SW0);
	nvboard_bind_pin(&top->b, 1, SW1);
	nvboard_bind_pin(&top->f, 1, LD0);

  nvboard_init();

  reset(top, 10);

  while(1) 
  {
    nvboard_update();
    single_cycle(top);
  }
}
