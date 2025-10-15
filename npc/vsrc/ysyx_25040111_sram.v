`ifndef YOSYS_STA
`ifndef RUNSOC

`include "HDR/ysyx_25040111_dpic.vh"

`define HEX_PATH "/home/dallous/Documents/ysyx-workbench/am-kernels/benchmarks/microbench/build/microbench-riscv32e-npc.hex"
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

`ifdef __ICARUS__
    reg [7:0] mem [0:6291456];
    initial begin
        $display("read hex from %s", `HEX_PATH);
        $readmemh(`HEX_PATH, mem);
    end
    wire [31:0] iaraddr = araddr & {4'b0, {26{1'b1}}, 2'b0};
    wire [31:0] mrdata = {mem[iaraddr | 32'b11], mem[iaraddr | 32'b10], mem[iaraddr | 32'b01], mem[iaraddr]};
`endif // __ICARUS__

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
            `ifdef __ICARUS__
                rdata_t <= mrdata;
                // $display("read iaddr %h data %h", araddr, mrdata);
            `else
                rdata_t <= pmem_read(araddr);
            `endif // __ICARUS__
            rvalid  <= 1'b1;
        end
        else if (rvalid & rready) begin
            rvalid <= 1'b0;            
        end
    end
    
    // memory write
    `ifdef __ICARUS__
        wire [31:0] iawaddr = awaddr & {4'b0, {26{1'b1}}, 2'b0};
    `else
        wire [7:0] wmask = {4'b0, wstrb};
    `endif
    assign awready = 1;
    assign wready = 1;
    assign bvalid = wready & wvalid;
    always @(posedge clock) begin
        if (awvalid & awready & wvalid & wready & wlast & bready) begin
            `ifdef __ICARUS__
                // $display("write mem %h", awaddr);
                if (awaddr == 32'ha00003f8)
                    $write("%c", wdata[7:0]);
                else begin
                    if (wstrb[0]) mem[iawaddr] <= wdata[7:0];
                    if (wstrb[1]) mem[iawaddr | 32'b01] <= wdata[15:8];
                    if (wstrb[2]) mem[iawaddr | 32'b10] <= wdata[23:16];
                    if (wstrb[3]) mem[iawaddr | 32'b11] <= wdata[31:24];
                end
            `else
                pmem_write(awaddr, wdata, wmask);
            `endif // __ICARUS__
        end
    end

endmodule

`endif // RUNSOC
`endif // YOSYS_STA
