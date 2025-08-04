`include "HDR/ysyx_25040111_inc.vh"
`include "MOD/ysyx_25040111_MuxKey.v"

`ifdef RUNSOC
`define PC_RESET 32'h30000000   
`else
`define PC_RESET 32'h80000000
`endif

module ysyx_25040111_pcu(
    input  clk,             // 时钟
    input reset,
    input ready,
    input  brench,          // 分支判断结果
    input  [9:8] opt,       // pc 跳转类型
    input  mret,            // 是否为 mret
    input [31:0] mret_addr, // mret 跳转地址
    input [31:0] imm,       // 立即数
    input [31:0] rs1_d,     // rs1 数据
    output reg [31:0] pc,
    output reg valid
);

    reg [31:0] ina, inb;
    wire [1:0] pc_ctl;
    
    assign pc_ctl = |opt[9:8] ? opt[9:8] : brench ? `INPC : `SNPC;
    always @(*) begin
        case (pc_ctl)
            2'b00: begin ina = pc; inb = 32'b0; end
            2'b01: begin ina = pc; inb = 32'd4; end
            2'b10: begin ina = pc; inb = imm; end
            2'b11: begin ina = rs1_d; inb = imm; end
        endcase
    end

    wire [31:0] dnpc_normal;
    assign dnpc_normal = ina + inb;

    // mret
    wire [31:0] dnpc;
    assign dnpc = mret ? mret_addr : dnpc_normal;

    always @(posedge clk) begin
        if (reset) begin
            pc <= `PC_RESET;
            valid <= 1;    
        end 
        else if (ready) begin
            pc <= dnpc;
            valid <= 1;            
        end
        else
            pc <= pc;

        if (valid & ~reset)
            valid <= 0; 
    end

endmodule
