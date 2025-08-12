`include "HDR/ysyx_25040111_inc.vh"
`include "HDR/ysyx_25040111_dpic.vh"
`include "ALU/ysyx_25040111_alu.v"

module ysyx_25040111_exu(
    input                   clock,
    input                   reset,
    
    input                   exe_valid,
    output                  exe_ready,
    input  [`OPT_HIGH:0]    opt,
    input  [4:0]            ard_in,
    input  [4:0]            ar1_in,
    input  [4:0]            ar2_in,
    input  [11:0]           acsrd_in,
    input  [31:0]           pc,
    input  [31:0]           imm,
    
    input  [31:0]           csri,
    input  [31:0]           rs1,
    input  [31:0]           rs2,

    output                  abt_valid,
    input                   abt_ready,
    output                  abt_men,

    output [4:0]            abt_ard,
    output [31:0]           abt_rd,
    output                  abt_gen,

    output [11:0]           abt_acsr,
    output [31:0]           abt_csr,
    output                  abt_sen,

    output                  abt_write,
    output [31:0]           abt_wdata,
    output [31:0]           abt_addr,
    output [1:0]            abt_mask, 
    output                  abt_rsign,
    
    output [31:0]           jump_pc,
    output                  jpc_ready,

    input                   abt_finish,
    input  [4:0]            abt_frd,
    output [31:0]           abt_pc
);

//-----------------------------------------------------------------
// External Interface
//-----------------------------------------------------------------
    
    assign exe_ready = ~exe_start & ~lock;

    assign abt_valid = exe_end;
    assign abt_men   = |eopt[11:10] & ~eopt[15];
    
    assign abt_ard   = ard;
    assign abt_rd    = mwt ? ecsr : rdo;
    assign abt_gen   = eopt[0];

    assign abt_acsr  = acsrd;
    assign abt_csr   = rdo;
    assign abt_sen   = mwt;

    assign abt_rsign = eopt[14];
    assign abt_write = ~eopt[12];
    assign abt_addr  = rdo;
    assign abt_wdata = ers2;
    assign abt_mask  = eopt[11:10];

    assign abt_pc    = epc;
    
    assign jpc_ready = jmpc_ok;
    assign jump_pc   = rd; 

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------

    // exu input data
    reg  [31:0]         ers2,   ecsr;
    reg  [31:0]         epc; 
    reg  [`OPT_HIGH:0]  eopt;
    reg  [4:0]          ard;
    reg  [11:0]         acsrd;

    // output data
    reg  [31:0]         rdo;

    // pipeline ctrl
    reg  [15:0]         rlock;
    reg                 exe_start;
    reg                 exe_end;
    reg                 jmpc_ok;

    // alu paramter
    reg  [31:0]         alu_p1, alu_p2;
    reg  [6:0]          alu_ctrl;
    wire [31:0]         rd;
    
    // read after write lock paramter
    wire lock = |(rlock & ((16'h1 << ard_in[3:0]) |
                           (16'h1 << ar1_in[3:0]) |
                           (16'h1 << ar2_in[3:0])));

    wire load = opt[12] & |opt[11:10] & ~opt[15];

    wire [15:0] ard_mask  = 16'h1 << ard_in[3:0];
    wire [15:0] frd_mask  = 16'h1 << abt_frd[3:0];

    // jump pc process
    wire jmp  = ~((eopt[9:8] == 2'b01) & |eopt[2:0]) | (eopt[12] & eopt[15]);
    wire mtp  = eopt[12] & eopt[15];
    
    wire [15:0] rlock_set = exe_ready & exe_valid & load ? rlock | ard_mask : rlock;
    wire [15:0] rlock_nxt = abt_finish ? rlock_set & ~frd_mask : rlock_set;

    // other ctrl
    wire mwt  = eopt[15] & eopt[10];
    wire mrd  = opt[15]  & opt[11];

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    // input data
    always @(posedge clock) begin
        if (reset) begin
            ers2 <= 0; ecsr <= 0;
            epc  <= 0; eopt <= `OPT_LEN'b0;
            ard  <= 5'b0; acsrd <= 12'b0;
        end
        else if (exe_start & ~exe_end) begin
            ers2 <= rs2; ecsr <= csri;
            epc  <= pc; eopt <= opt;
            ard <= ard_in; acsrd <= acsrd_in;
        end
    end

    // exe start
    always @(posedge clock) begin
        if (reset)
            exe_start <= 1'b0;
        else if (exe_ready & exe_valid)
            exe_start <= 1'b1;
        else if (exe_start & abt_valid & abt_ready)
            exe_start <= 1'b0;
    end

    // exe end
    always @(posedge clock) begin
        if (reset)
            exe_end <= 1'b0;
        else if (exe_start & ~exe_end)
            exe_end <= 1'b1;
        else if (abt_valid & abt_ready)
            exe_end <= 1'b0;
    end

    // executing
    // 假定已经有 clk/reset 和原来的信号定义
    wire exe_branch0 = exe_ready & exe_valid;        // 原来第一个 case
    wire exe_branch1 = exe_start & ~exe_end;         // 原来第二个 case
    wire write_en    = exe_branch0 | exe_branch1;    // 只有这两种情况要写寄存器

    // 复用常量
    wire [31:0] CONST_4 = 32'd4;
    wire [31:0] CONST_0 = 32'd0;

    // --------- mode0 (exe_branch0) 的组合输出 ---------
    wire [31:0] p1_mode0 = (opt[4:3] == 2'b00) ? imm :
                        (opt[4:3] == 2'b01) ? pc  :
                        rs1; // 2'b10 和 2'b11 都是 rs1

    wire [31:0] p2_mode0 = (opt[4:3] == 2'b00) ? CONST_0 :
                        (opt[4:3] == 2'b01) ? imm :
                        (opt[4:3] == 2'b11) ? imm :
                        /*2'b10*/            (mrd ? csri : rs2);

    // alu_ctrl for branch0
    wire [6:0] alu_ctrl_mode0; // 根据你原来的宽度调整这里的位宽
    assign alu_ctrl_mode0 = { opt[7:5], (opt[12:10] == 3'b100), opt[15:13] };

    // --------- mode1 (exe_branch1) 的组合输出 ---------
    wire [31:0] p1_mode1 = (opt[9:8] == 2'b00) ? (mtp ? csri : pc) :
                        (opt[9:8] == 2'b01) ? pc :
                        (opt[9:8] == 2'b10) ? pc :
                        rs1;

    wire [31:0] p2_mode1 = (opt[9:8] == 2'b00) ? (mtp ? CONST_0 : (rd[0] ? imm : CONST_4)) :
                        (opt[9:8] == 2'b01) ? CONST_4 :
                        (opt[9:8] == 2'b10) ? imm :
                        imm; // 2'b11 -> imm

    // alu_ctrl for branch1 is fixed
    wire [6:0] alu_ctrl_mode1;
    assign alu_ctrl_mode1 = { `ADD, 1'b0, `EMPTY }; // 确认宏定义宽度匹配

    // --------- 根据当前是哪条分支选组合结果 ---------
    wire [31:0] alu_p1_w = exe_branch0 ? p1_mode0 :
                        exe_branch1 ? p1_mode1 :
                        32'd0; // idle 时可保持某默认或上一个值（但不会写入寄存器）

    wire [31:0] alu_p2_w = exe_branch0 ? p2_mode0 :
                        exe_branch1 ? p2_mode1 :
                        32'd0;

    wire [6:0] alu_ctrl_w = exe_branch0 ? alu_ctrl_mode0 :
                            exe_branch1 ? alu_ctrl_mode1 :
                            7'b0;

    // --------- 寄存器写入（有写使能） ---------
    always @(posedge clock) begin
        if (reset) begin
            alu_p1 <= 32'd0;
            alu_p2 <= 32'd0;
            alu_ctrl <= 7'b0;
        end else if (write_en) begin
            alu_p1 <= alu_p1_w;
            alu_p2 <= alu_p2_w;
            alu_ctrl <= alu_ctrl_w;
        end
        // else 保持原值（避免不必要写入）
    end

    // rdo
    always @(posedge clock) begin
        if (reset)
            rdo <= 0;
        else if (exe_start & ~exe_end)
            rdo <= rd;
    end

    // jmpc_ok
    always @(posedge clock) begin
        if (reset)
            jmpc_ok <= 1'b0;
        else if (exe_start & ~exe_end)
            jmpc_ok <= 1'b1;
        else if (jmpc_ok)
            jmpc_ok <= 1'b0;
    end

    // read after write process
    always @(posedge clock) begin
        if (reset) rlock <= 16'b0;
        else rlock <= rlock_nxt;
    end

//-----------------------------------------------------------------
// MODULE INSTANCES
//-----------------------------------------------------------------

    // ALU
    ysyx_25040111_alu u_alu(
        .var1 	(alu_p1         ),
        .var2 	(alu_p2         ),
        .opt  	(alu_ctrl[6:4]  ),
        .snpc   (alu_ctrl[3]    ),
        .ext    (alu_ctrl[0]    ),
        .sign   (alu_ctrl[1]    ),
        .negate (alu_ctrl[2]    ),
        .res  	(rd             )
    );

//-----------------------------------------------------------------
// Combinational Logic
//-----------------------------------------------------------------

`ifndef YOSYS_STA
    // EBREADK
    wire [31:0] eret;
    assign eret = opt[15] ? rs1 : 32'd9;
    always @(*) begin
        if (opt == `EBREAK_INST)
            ebreak(eret);
    end
`endif // YOSYS_STA

endmodule
