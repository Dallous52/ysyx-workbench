`ifndef REGISTERFILE_V
`define REGISTERFILE_V

module ysyx_25040111_RegisterFile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
  input clk,
  input wen,
  input [1:0] ren,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
  input [ADDR_WIDTH-1:0] raddr1, raddr2,
  output [DATA_WIDTH-1:0] rdata1, rdata2
);

    reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] raddr_m [1:0];

    // 写入
    always @(posedge clk) begin
        if (wen) begin
          // $display("waddr: %d, wdata: %h\n", waddr, wdata);
          rf[waddr] <= wdata;
          rf[0] <= 0;
        end
    end

    // 读寄存器使能判断
    assign raddr_m[0] = ren[0] ? raddr1 : {ADDR_WIDTH{1'b0}};
    assign raddr_m[1] = ren[1] ? raddr2 : {ADDR_WIDTH{1'b0}};

    // 读取
    assign rdata1 = raddr_m[0] == {ADDR_WIDTH{1'b0}} ? {DATA_WIDTH{1'b0}} : rf[raddr_m[0]];
    assign rdata2 = raddr_m[1] == {ADDR_WIDTH{1'b0}} ? {DATA_WIDTH{1'b0}} : rf[raddr_m[1]];

endmodule

`endif