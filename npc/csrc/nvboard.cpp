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
