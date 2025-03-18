// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


VL_ATTR_COLD void Vtop___024root__trace_init_sub__TOP__0(Vtop___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+1,"clk", false,-1);
    tracep->declBit(c+2,"rst", false,-1);
    tracep->declBus(c+3,"btn", false,-1, 4,0);
    tracep->declBus(c+4,"sw", false,-1, 7,0);
    tracep->declBit(c+5,"ps2_clk", false,-1);
    tracep->declBit(c+6,"ps2_data", false,-1);
    tracep->declBit(c+7,"uart_rx", false,-1);
    tracep->declBit(c+8,"uart_tx", false,-1);
    tracep->declBus(c+9,"ledr", false,-1, 15,0);
    tracep->declBit(c+10,"VGA_CLK", false,-1);
    tracep->declBit(c+11,"VGA_HSYNC", false,-1);
    tracep->declBit(c+12,"VGA_VSYNC", false,-1);
    tracep->declBit(c+13,"VGA_BLANK_N", false,-1);
    tracep->declBus(c+14,"VGA_R", false,-1, 7,0);
    tracep->declBus(c+15,"VGA_G", false,-1, 7,0);
    tracep->declBus(c+16,"VGA_B", false,-1, 7,0);
    tracep->declBus(c+17,"seg0", false,-1, 7,0);
    tracep->declBus(c+18,"seg1", false,-1, 7,0);
    tracep->declBus(c+19,"seg2", false,-1, 7,0);
    tracep->declBus(c+20,"seg3", false,-1, 7,0);
    tracep->declBus(c+21,"seg4", false,-1, 7,0);
    tracep->declBus(c+22,"seg5", false,-1, 7,0);
    tracep->declBus(c+23,"seg6", false,-1, 7,0);
    tracep->declBus(c+24,"seg7", false,-1, 7,0);
    tracep->pushNamePrefix("top ");
    tracep->declBit(c+1,"clk", false,-1);
    tracep->declBit(c+2,"rst", false,-1);
    tracep->declBus(c+3,"btn", false,-1, 4,0);
    tracep->declBus(c+4,"sw", false,-1, 7,0);
    tracep->declBit(c+5,"ps2_clk", false,-1);
    tracep->declBit(c+6,"ps2_data", false,-1);
    tracep->declBit(c+7,"uart_rx", false,-1);
    tracep->declBit(c+8,"uart_tx", false,-1);
    tracep->declBus(c+9,"ledr", false,-1, 15,0);
    tracep->declBit(c+10,"VGA_CLK", false,-1);
    tracep->declBit(c+11,"VGA_HSYNC", false,-1);
    tracep->declBit(c+12,"VGA_VSYNC", false,-1);
    tracep->declBit(c+13,"VGA_BLANK_N", false,-1);
    tracep->declBus(c+14,"VGA_R", false,-1, 7,0);
    tracep->declBus(c+15,"VGA_G", false,-1, 7,0);
    tracep->declBus(c+16,"VGA_B", false,-1, 7,0);
    tracep->declBus(c+17,"seg0", false,-1, 7,0);
    tracep->declBus(c+18,"seg1", false,-1, 7,0);
    tracep->declBus(c+19,"seg2", false,-1, 7,0);
    tracep->declBus(c+20,"seg3", false,-1, 7,0);
    tracep->declBus(c+21,"seg4", false,-1, 7,0);
    tracep->declBus(c+22,"seg5", false,-1, 7,0);
    tracep->declBus(c+23,"seg6", false,-1, 7,0);
    tracep->declBus(c+24,"seg7", false,-1, 7,0);
    tracep->pushNamePrefix("u_dualctl ");
    tracep->declBit(c+25,"a", false,-1);
    tracep->declBit(c+26,"b", false,-1);
    tracep->declBit(c+27,"f", false,-1);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void Vtop___024root__trace_init_top(Vtop___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_init_top\n"); );
    // Body
    Vtop___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vtop___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtop___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vtop___024root__trace_register(Vtop___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&Vtop___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&Vtop___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&Vtop___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vtop___024root__trace_full_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vtop___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_full_top_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vtop___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtop___024root__trace_full_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullBit(oldp+1,(vlSelf->clk));
    bufp->fullBit(oldp+2,(vlSelf->rst));
    bufp->fullCData(oldp+3,(vlSelf->btn),5);
    bufp->fullCData(oldp+4,(vlSelf->sw),8);
    bufp->fullBit(oldp+5,(vlSelf->ps2_clk));
    bufp->fullBit(oldp+6,(vlSelf->ps2_data));
    bufp->fullBit(oldp+7,(vlSelf->uart_rx));
    bufp->fullBit(oldp+8,(vlSelf->uart_tx));
    bufp->fullSData(oldp+9,(vlSelf->ledr),16);
    bufp->fullBit(oldp+10,(vlSelf->VGA_CLK));
    bufp->fullBit(oldp+11,(vlSelf->VGA_HSYNC));
    bufp->fullBit(oldp+12,(vlSelf->VGA_VSYNC));
    bufp->fullBit(oldp+13,(vlSelf->VGA_BLANK_N));
    bufp->fullCData(oldp+14,(vlSelf->VGA_R),8);
    bufp->fullCData(oldp+15,(vlSelf->VGA_G),8);
    bufp->fullCData(oldp+16,(vlSelf->VGA_B),8);
    bufp->fullCData(oldp+17,(vlSelf->seg0),8);
    bufp->fullCData(oldp+18,(vlSelf->seg1),8);
    bufp->fullCData(oldp+19,(vlSelf->seg2),8);
    bufp->fullCData(oldp+20,(vlSelf->seg3),8);
    bufp->fullCData(oldp+21,(vlSelf->seg4),8);
    bufp->fullCData(oldp+22,(vlSelf->seg5),8);
    bufp->fullCData(oldp+23,(vlSelf->seg6),8);
    bufp->fullCData(oldp+24,(vlSelf->seg7),8);
    bufp->fullBit(oldp+25,((1U & (IData)(vlSelf->sw))));
    bufp->fullBit(oldp+26,((1U & ((IData)(vlSelf->sw) 
                                  >> 1U))));
    bufp->fullBit(oldp+27,((1U & ((IData)(vlSelf->sw) 
                                  ^ ((IData)(vlSelf->sw) 
                                     >> 1U)))));
}
