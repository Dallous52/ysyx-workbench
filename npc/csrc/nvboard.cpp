#include <nvboard.h>

#include "Vtop.h"

int main()
{
    Vtop* top = new Vtop();

    nvboard_bind_pin(&top->a, 1, SW0);
    nvboard_bind_pin(&top->b, 1, SW1);
    nvboard_bind_pin(&top->f, 1, LD0);

    nvboard_init();

    bool tmp = false;
    while(1)
    {
        top->eval();
        nvboard_update();
    }

    nvboard_quit();
}
