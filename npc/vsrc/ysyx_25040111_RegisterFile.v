module ysyx_25040111_RegisterFile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
  input clk,
  input wen,
  input [1:0] ren,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
  input [ADDR_WIDTH-1:0] raddr [1:0],
  output [DATA_WIDTH-1:0] rdata [1:0]
);

    reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] raddr_m [1:0];

    // 写入
    always @(posedge clk) begin
        if (wen) begin
          rf[waddr] <= wdata;
          $display("rg = %d;  data: 0x%h\n", waddr, wdata);
        end
    end

    // 读寄存器使能判断
    assign raddr_m[0] = ren[0] ? raddr[0] : {ADDR_WIDTH{1'b0}};
    assign raddr_m[1] = ren[1] ? raddr[1] : {ADDR_WIDTH{1'b0}};

    // 读取
    assign rdata[0] = raddr_m[0] == {ADDR_WIDTH{1'b0}} ? {DATA_WIDTH{1'b0}} : rf[raddr_m[0]];
    assign rdata[1] = raddr_m[1] == {ADDR_WIDTH{1'b0}} ? {DATA_WIDTH{1'b0}} : rf[raddr_m[1]];

endmodule
