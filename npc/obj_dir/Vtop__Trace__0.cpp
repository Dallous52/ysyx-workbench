// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


void Vtop___024root__trace_chg_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtop___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_top_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtop___024root__trace_chg_sub_0((&vlSymsp->TOP), bufp);
}

void Vtop___024root__trace_chg_sub_0(Vtop___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgBit(oldp+0,(vlSelf->clk));
    bufp->chgBit(oldp+1,(vlSelf->rst));
    bufp->chgCData(oldp+2,(vlSelf->btn),5);
    bufp->chgCData(oldp+3,(vlSelf->sw),8);
    bufp->chgBit(oldp+4,(vlSelf->ps2_clk));
    bufp->chgBit(oldp+5,(vlSelf->ps2_data));
    bufp->chgBit(oldp+6,(vlSelf->uart_rx));
    bufp->chgBit(oldp+7,(vlSelf->uart_tx));
    bufp->chgSData(oldp+8,(vlSelf->ledr),16);
    bufp->chgBit(oldp+9,(vlSelf->VGA_CLK));
    bufp->chgBit(oldp+10,(vlSelf->VGA_HSYNC));
    bufp->chgBit(oldp+11,(vlSelf->VGA_VSYNC));
    bufp->chgBit(oldp+12,(vlSelf->VGA_BLANK_N));
    bufp->chgCData(oldp+13,(vlSelf->VGA_R),8);
    bufp->chgCData(oldp+14,(vlSelf->VGA_G),8);
    bufp->chgCData(oldp+15,(vlSelf->VGA_B),8);
    bufp->chgCData(oldp+16,(vlSelf->seg0),8);
    bufp->chgCData(oldp+17,(vlSelf->seg1),8);
    bufp->chgCData(oldp+18,(vlSelf->seg2),8);
    bufp->chgCData(oldp+19,(vlSelf->seg3),8);
    bufp->chgCData(oldp+20,(vlSelf->seg4),8);
    bufp->chgCData(oldp+21,(vlSelf->seg5),8);
    bufp->chgCData(oldp+22,(vlSelf->seg6),8);
    bufp->chgCData(oldp+23,(vlSelf->seg7),8);
    bufp->chgBit(oldp+24,((1U & (IData)(vlSelf->sw))));
    bufp->chgBit(oldp+25,((1U & ((IData)(vlSelf->sw) 
                                 >> 1U))));
    bufp->chgBit(oldp+26,((1U & ((IData)(vlSelf->sw) 
                                 ^ ((IData)(vlSelf->sw) 
                                    >> 1U)))));
}

void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_cleanup\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
