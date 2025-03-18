#ifdef VSIM_T
#include <verilated.h>
#include <verilated_vcd_c.h>

void verilator_main_loop(Vtop* top);
#endif // VSIM_T


#ifdef NVBD_T
#include <nvboard.h>

void nvboard_bind_all_pins(Vtop* top);

void single_cycle(Vtop& dut);
void reset(Vtop& dut, int n);
#endif // NVBD_T


#include "Vtop.h"


int main(int argc, char** argv)
{
    Vtop* top = new Vtop();

#ifdef NVBD_T
    // 接下来的四行代码用于设置波形存储为VCD文件
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    top->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

    verilator_main_loop(top);

    m_trace->close();
    delete top;
#endif // NVBD_T

#ifdef VSIM_T 
    nvboard_bind_all_pins(top);

    nvboard_init();

    while(1)
    {
        top->eval();
        nvboard_update();
    }

    nvboard_quit();
#endif // VSIM_T

    return 0;
}


#ifdef NVBD_T
#include <nvboard.h>

void nvboard_bind_all_pins(Vtop* top) 
{
    nvboard_bind_pin( &top->VGA_VSYNC, 1, VGA_VSYNC);
    nvboard_bind_pin( &top->VGA_HSYNC, 1, VGA_HSYNC);
    nvboard_bind_pin( &top->VGA_BLANK_N, 1, VGA_BLANK_N);
    nvboard_bind_pin( &top->VGA_R, 8, VGA_R7, VGA_R6, VGA_R5, VGA_R4, VGA_R3, VGA_R2, VGA_R1, VGA_R0);
    nvboard_bind_pin( &top->VGA_G, 8, VGA_G7, VGA_G6, VGA_G5, VGA_G4, VGA_G3, VGA_G2, VGA_G1, VGA_G0);
    nvboard_bind_pin( &top->VGA_B, 8, VGA_B7, VGA_B6, VGA_B5, VGA_B4, VGA_B3, VGA_B2, VGA_B1, VGA_B0);
    nvboard_bind_pin( &top->ledr, 16, LD15, LD14, LD13, LD12, LD11, LD10, LD9, LD8, LD7, LD6, LD5, LD4, LD3, LD2, LD1, LD0);
    nvboard_bind_pin( &top->sw, 8, SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0);
    nvboard_bind_pin( &top->btn, 5, BTNL, BTNU, BTNC, BTND, BTNR);
    nvboard_bind_pin( &top->seg0, 8, SEG0A, SEG0B, SEG0C, SEG0D, SEG0E, SEG0F, SEG0G, DEC0P);
    nvboard_bind_pin( &top->seg1, 8, SEG1A, SEG1B, SEG1C, SEG1D, SEG1E, SEG1F, SEG1G, DEC1P);
    nvboard_bind_pin( &top->seg2, 8, SEG2A, SEG2B, SEG2C, SEG2D, SEG2E, SEG2F, SEG2G, DEC2P);
    nvboard_bind_pin( &top->seg3, 8, SEG3A, SEG3B, SEG3C, SEG3D, SEG3E, SEG3F, SEG3G, DEC3P);
    nvboard_bind_pin( &top->seg4, 8, SEG4A, SEG4B, SEG4C, SEG4D, SEG4E, SEG4F, SEG4G, DEC4P);
    nvboard_bind_pin( &top->seg5, 8, SEG5A, SEG5B, SEG5C, SEG5D, SEG5E, SEG5F, SEG5G, DEC5P);
    nvboard_bind_pin( &top->seg6, 8, SEG6A, SEG6B, SEG6C, SEG6D, SEG6E, SEG6F, SEG6G, DEC6P);
    nvboard_bind_pin( &top->seg7, 8, SEG7A, SEG7B, SEG7C, SEG7D, SEG7E, SEG7F, SEG7G, DEC7P);
    nvboard_bind_pin( &top->ps2_clk, 1, PS2_CLK);
    nvboard_bind_pin( &top->ps2_data, 1, PS2_DAT);
    nvboard_bind_pin( &top->uart_tx, 1, UART_TX);
    nvboard_bind_pin( &top->uart_rx, 1, UART_RX);
}


void single_cycle(Vtop& dut)
{
    dut.clk = 0; dut.eval();
    dut.clk = 1; dut.eval();
}
  
void reset(Vtop& dut, int n)
{
    dut.rst = 1;
    while (n -- > 0) single_cycle();
    dut.rst = 0;
}
#endif // NVBD_T