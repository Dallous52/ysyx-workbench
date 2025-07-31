`ifndef RUNSOC

`include "HDR/ysyx_25040111_dpic.vh"

`ifdef YOSYS_STA
`include "MOD/ysyx_25040111_RegisterFile.v"    
`endif

`define READY_TIME 8'd1

module ysyx_25040111_sram(
    input wire clk,
    input wire [31:0] araddr,
    input wire arvalid,
    output wire arready,

    output wire [31:0] rdata,
    output wire [1:0] rresp,
    output reg rvalid,
    input wire  rready,

    input wire [31:0] awaddr,
    input wire awvalid,
    output wire awready,

    input wire [31:0] wdata,
    input wire [3:0] wstrb, // wmask
    input wire wvalid,
    output wire wready,

    output wire [1:0] bresp,
    output reg bvalid,
    input wire bready
);
    // memory read
    reg [31:0] rdata_t;

    assign arready = 1;
    assign rresp = 2'b00;
    assign rdata = rdata_t;
    always @(posedge clk) begin
        // 准备开始
        if (arvalid & arready) begin
        `ifndef YOSYS_STA
            rdata_t <= pmem_read(araddr);
        `endif
            rvalid <= 1; // 读取完毕
        end
        else if (rvalid & rready) begin
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
    wire [7:0] wmask;
    assign wmask = {4'b0, wstrb};

    assign awready = 1;
    assign wready = 1;
    assign bresp = 2'b0;
    always @(posedge clk) begin
        // 写入参数读取准备
        if (awvalid & awready & wvalid & wready) begin
        `ifndef YOSYS_STA
            pmem_write(awaddr, wdata, wmask);
        `endif
        end
        
        if (wvalid & wready) begin
            bvalid <= 1;
        end
        else if (bvalid & bready) begin
            bvalid <= 0;
        end
    end

endmodule

`endif // YOSYS_STA
