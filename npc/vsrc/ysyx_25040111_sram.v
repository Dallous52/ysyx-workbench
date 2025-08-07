`ifndef YOSYS_STA
`ifndef RUNSOC

`include "HDR/ysyx_25040111_dpic.vh"

`define READY_TIME 8'd1

module ysyx_25040111_sram(
    input           clock,
    input           reset,
    input [31:0]    araddr,
    input [2:0]     arsize,
    input           arvalid,
    output          arready,

    output [31:0]   rdata,
    output reg      rvalid,
    input           rready,

    input [31:0]    awaddr,
    input           awvalid,
    input [2:0]     awsize,
    output          awready,

    input [31:0]    wdata,
    input [3:0]     wstrb,
    input           wvalid,
    input           wlast,
    output          wready,
    output          bvalid,
    input           bready
);
    // memory read
    reg [31:0] rdata_t;
    assign arready = 1;
    assign rdata = rdata_t;
    always @(posedge clock) begin
        if (reset)begin
            rdata_t <= 0;
            rvalid <= 1'b0;            
        end
        else if (arvalid & arready) begin
            rdata_t <= pmem_read(araddr);
            rvalid  <= 1'b1;
        end
        else if (rvalid & rready & |hehe) begin
            rvalid <= 1'b0;            
        end
    end
    
    // memory write
    wire [7:0] wmask = {4'b0, wstrb};
    assign awready = 1;
    assign wready = 1;
    assign bvalid = wready & wvalid;
    always @(*) begin
        if (awvalid & awready & wvalid & wready & wlast & bready) begin
            pmem_write(awaddr, wdata, wmask);
        end
    end

    wire [2:0] hehe = awsize + arsize + 1;

endmodule

`endif // RUNSOC
`endif // YOSYS_STA
