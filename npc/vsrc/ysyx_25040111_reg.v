module ysyx_25040111_reg (
    input         clock,
    input         wen,
    input  [1:0]  ren,
    input  [31:0] wdata,
    input  [3:0]  waddr,
    input  [3:0]  ars1, 
    input  [3:0]  ars2,
    output [31:0] rs1, 
    output [31:0] rs2
);

    reg  [31:0] rf [15:0];

    // 写入
    always @(posedge clock) begin
        if (wen)
          rf[waddr] <= |waddr ? wdata : 0;
    end

    // 读取
    wire   eq1 = ars1 == waddr;
    wire   eq2 = ars2 == waddr;

    assign rs1 = ren[0] ? wen & eq1 ? wdata : rf[ars1] : 0;
    assign rs2 = ren[1] ? wen & eq2 ? wdata : rf[ars2] : 0;

endmodule
