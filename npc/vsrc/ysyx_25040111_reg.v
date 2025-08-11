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

    // 我们只保存寄存器 1..15（共 15 个 32-bit 单元），索引映射为 [0..14] 对应 arch[1..15]
    reg  [31:0] rf [0:14];

    // 写：若写地址为 1..15 才写入
    always @(posedge clock) begin
        if (wen && (waddr != 4'd0)) begin
            rf[waddr - 1] <= wdata; // waddr in 1..15 maps to rf[0..14]
        end
    end

    // forwarding 条件：只有当写入的是 1..15 且地址匹配时才前递
    wire forward1 = (wen && (waddr != 4'd0) && (ars1 == waddr));
    wire forward2 = (wen && (waddr != 4'd0) && (ars2 == waddr));

    // 读：若 ars == 0 直接返回常数 0，否则从 rf[ars-1] 读出
    wire [31:0] rf_rs1 = (ars1 == 4'd0) ? 32'd0 : rf[ars1 - 1];
    wire [31:0] rf_rs2 = (ars2 == 4'd0) ? 32'd0 : rf[ars2 - 1];

    assign rs1 = ren[0] ? (forward1 ? wdata : rf_rs1) : 32'd0;
    assign rs2 = ren[1] ? (forward2 ? wdata : rf_rs2) : 32'd0;
    
endmodule
