`ifndef RUNSOC

`include "HDR/ysyx_20540111_dpic.vh"

`ifdef YOSYS_STA
`include "MOD/ysyx_25040111_RegisterFile.v"    
`endif

`define READY_TIME 8'd1

module ysyx_25040111_sram(
    input clk,
    input [31:0] araddr,
    input arvalid,
    output arready,

    output reg [31:0] rdata,
    output [1:0] rresp,
    output rvalid,
    input rready,

    input [31:0] awaddr,
    input awvalid,
    output awready,

    input [31:0] wdata,
    input [3:0] wstrb, // wmask
    input wvalid,
    output wready,

    output [1:0] bresp,
    output bvalid,
    input bready
);
    // memory read
    reg [31:0] rdata_t;

    assign arready = 1;
    always @(posedge clk) begin
        // 准备开始
        if (arvalid & arready) begin
        `ifndef YOSYS_STA
            rdata_t <= pmem_read(araddr);
        `endif
            rvalid <= 1; // 读取完毕
        end

        // 完成传输
        if (rvalid & rready) begin
            rdata <= rdata_t;
            rresp <= 2'b00;
            rvalid <= 0;            
        end
    end

`ifdef YOSYS_STA
    ysyx_25040111_RegisterFile #(8, 32) u_rom2_t(
        .clk   	(clk    ),
        .wen   	(wtstart & wvalid),
        .ren   	({arvalid & arready, 1'b0}),
        .wdata 	(wdata),
        .waddr 	(awaddr[7:0]),
        .raddr1 (araddr[7:0]),
        .rdata1 (rdata_t)
    );
`endif

    // memory write
    reg wtstart;
    wire [7:0] wmask;
    assign wmask = {4'b0, wstrb};

    assign awready = 1;
    assign wready = 1;
    always @(posedge clk) begin
        // 写入参数读取准备
        if (awvalid & awready) begin
            wtstart <= 1;
        end

        if (wtstart & wvalid) begin
        `ifndef YOSYS_STA
            pmem_write(awaddr, wdata, wmask);
        `endif
            wready <= 1;
            wtstart <= 0;       
        end

        // 写入结束
        if (wvalid & wready) begin
            wready <= 0;
            bvalid <= 1;
        end

        // 读回复信号
        if (bvalid & bready) begin
            bresp <= 2'b0;
            bvalid <= 0;
        end
    end

endmodule

`endif // YOSYS_STA
