`include "HDR/ysyx_25040111_inc.vh"
`include "HDR/ysyx_25040111_dpic.vh"
`include "MOD/ysyx_25040111_MuxKey.v"

module ysyx_25040111_lsu (
    input clk,          // 时钟
    input ready,
    input wen,          // 写使能
    input ren,          // 读使能
    input sign,         // 有无符号标志
    input [1:0] mask,   // 掩码选择
    input [31:0] addr,  // 内存操作地址
    input [31:0] wdata, // 写入数据
    input [7:0] tlen,   // 突发传输次数
    output [31:0] rdata,// 读出数据
    output valid

`ifdef RUNSOC
    ,input io_master_awready,
    output io_master_awvalid,
    output [31:0] io_master_awaddr,
    output [3:0] io_master_awid,
    output [7:0] io_master_awlen,
    output [2:0] io_master_awsize,
    output [1:0] io_master_awburst,

    input io_master_wready,
    output io_master_wvalid,
    output [31:0] io_master_wdata,
    output [3:0] io_master_wstrb,
    output io_master_wlast,

    output io_master_bready,
    input io_master_bvalid,
    input [1:0] io_master_bresp,
    input [3:0] io_master_bid,

    input io_master_arready,
    output io_master_arvalid,
    output [31:0] io_master_araddr,
    output [3:0] io_master_arid,
    output [7:0] io_master_arlen,
    output [2:0] io_master_arsize,
    output [1:0] io_master_arburst,

    output io_master_rready,
    input io_master_rvalid,
    input [1:0] io_master_rresp,
    input [31:0] io_master_rdata,
    input io_master_rlast,
    input [3:0] io_master_rid
`endif // RUNSOC
);

    reg arvalid;
    reg awvalid, wvalid;
    wire arready, awready;
    wire rvalid, rready;
    wire wready, bready; 
    wire bvalid;
    wire [1:0] bresp, rresp;
    reg wlast;

    reg [31:0] rmem;
    reg valid_t;

    wire [3:0] wmask;
    ysyx_25040111_MuxKey #(4, 2, 4) c_wmask(wmask, mask, {
        2'b00, 4'h0,
        2'b01, 4'b0001 << addr[1:0],
        2'b10, addr[1] ? 4'b1100 : 4'b0011,
        2'b11, 4'b1111
    });

    wire [2:0] tsize;
    ysyx_25040111_MuxKey #(4, 2, 3) c_tsize(tsize, mask, {
        2'b00, 3'b0,
        2'b01, 3'b000,
        2'b10, 3'b001,
        2'b11, 3'b010
    });

    wire [31:0] wmem;
    ysyx_25040111_MuxKey #(4, 2, 32) c_wt_data(wmem, addr[1:0], {
        2'b00, wdata,
        2'b01, wdata << 8,
        2'b10, wdata << 16,
        2'b11, wdata << 24
    });

    wire is_clint = (addr >= `DEV_CLINT && addr <= `DEV_CLINT_END);

`ifdef RUNSOC
    assign arvalid_clint    = is_clint ? arvalid         : 1'b0;
    assign arready          = is_clint ? arready_clint   : io_master_arready;
    assign rresp            = is_clint ? rresp_clint     : io_master_rresp;
    assign rvalid           = is_clint ? rvalid_clint    : io_master_rvalid;
    assign rready_clint     = is_clint ? rready          : 1'b0;

    assign awready           = is_clint ? 1'b0 : io_master_awready;
    assign io_master_awvalid = is_clint ? 1'b0 : awvalid;
    assign io_master_awaddr  = is_clint ? 32'b0 : addr;
    assign io_master_awid    = 4'b0;
    assign io_master_awlen   = 8'b0;
    assign io_master_awsize  = is_clint ? 3'b0 : tsize;
    assign io_master_awburst = 2'b0;

    assign wready             = is_clint ? 1'b0  : io_master_wready;
    assign io_master_wvalid   = is_clint ? 1'b0  : wvalid;
    assign io_master_wdata    = is_clint ? 32'b0 : wmem;
    assign io_master_wstrb    = is_clint ? 4'b0  : wmask;
    assign io_master_wlast    = is_clint ? 1'b0  : wlast;

    assign io_master_bready   = is_clint ? 1'b0 : bready;
    assign bvalid             = is_clint ? 1'b0 : io_master_bvalid;
    assign bresp              = is_clint ? 2'b0 : io_master_bresp;

    assign io_master_arvalid  = is_clint ? 1'b0 : arvalid;
    assign io_master_araddr   = is_clint ? 32'b0 : addr;
    assign io_master_arid     = 4'b0;
    assign io_master_arlen    = 8'b0;
    assign io_master_arsize   = is_clint ? 3'b0 : tsize;
    assign io_master_arburst  = 2'b0;

    assign io_master_rready   = is_clint ? 1'b0 : rready;

`else
    assign arready = is_clint ? arready_clint : arready_sram;
    assign rvalid = is_clint ? rvalid_clint : rvalid_sram;
    assign rresp = is_clint ? rresp_clint : rresp_sram;
`endif // RUNSOC
  
    // memory read
    assign rready = 1;
    always @(posedge clk) begin
        
        // 地址有效
        if (ren & ready)
            arvalid <= 1;

        if (arvalid & arready)
            arvalid <= 0;
    end

    // memory write
    assign bready = 1;
    always @(posedge clk) begin
        // 地址有效
        if (wen & ready) begin
            awvalid <= 1;
            wvalid <= 1;
            wlast <= 1;
        end

        if (awvalid & awready) begin
            awvalid <= 0;
        end

        // 写入参数
        if (wvalid & wready) begin
            wlast <= 0;
            wvalid <= 0;   
        end
    end

    assign valid = wen | ren ? valid_t : ready;

    always @(posedge clk) begin
        if (rvalid & rready) begin
        `ifdef RUNSOC 
            $display("rdata: %h", io_master_rdata);
        `endif
            rmem <= is_clint ? rmem_clint : 
            `ifdef RUNSOC 
                io_master_rdata;
            `else
                rmem_sram;
            `endif
            valid_t <= 1;
        end
        else if (bready & bvalid) begin
            valid_t <= 1;
        end
        else if (valid_t)
            valid_t <= 0;

    `ifndef YOSYS_STA
        if (|rresp | |bresp)
            ebreak(5);
    `endif // YOSYS_STA
    end

`ifdef RUNSOC
    wire arvalid_clint, rready_clint;
    wire [1:0] rresp_clint;
    wire arready_clint;
    wire rvalid_clint;
    wire [31:0] rmem_clint;
    ysyx_25040111_clint u_ysyx_25040111_clint(
        .clk     	(clk),
        .araddr  	(addr),
        .arvalid 	(arvalid_clint),
        .arready 	(arready_clint),
        .rdata   	(rmem_clint),
        .rresp   	(rresp_clint),
        .rvalid  	(rvalid_clint),
        .rready  	(rready_clint)
    );
`else // RUNSOC
    wire [1:0] rresp_clint;
    wire arready_clint;
    wire rvalid_clint;
    wire [31:0] rmem_clint;
    ysyx_25040111_clint u_ysyx_25040111_clint(
        .clk     	(clk),
        .araddr  	(addr),
        .rdata   	(rmem_clint),
        .arvalid 	(is_clint ? arvalid : 0),
        .arready 	(arready_clint),
        .rresp   	(rresp_clint),
        .rvalid  	(rvalid_clint),
        .rready  	(rready)
    );

    wire arready_sram;
    wire [1:0] rresp_sram;
    wire rvalid_sram;
    wire [31:0] rmem_sram;
    ysyx_25040111_sram u_ysyx_25040111_sram(
        .clk     	(clk        ),
        .araddr  	(addr       ),
        .awaddr  	(addr       ),
        .wdata   	(wmem       ),
        .rdata   	(rmem_sram  ),
        .wstrb   	(wmask      ),
        .arready 	(arready_sram   ),
        .rresp   	(rresp_sram     ),
        .rvalid  	(rvalid_sram    ),
        .awready 	(awready        ),
        .wready  	(wready         ),
        .bresp   	(bresp          ),
        .bvalid  	(bvalid         ),
        .wvalid  	(~is_clint ? wvalid   : 0),
        .rready  	(~is_clint ? rready   : 0),
        .arvalid 	(~is_clint ? arvalid  : 0),
        .awvalid 	(~is_clint ? awvalid  : 0),
        .bready  	(bready)
    );
`endif // NOT RUNSOC

    wire [31:0] offset;
    ysyx_25040111_MuxKey #(4, 2, 32) c_rd_data(offset, addr[1:0], {
        2'b00, rmem,
        2'b01, rmem >> 8,
        2'b10, rmem >> 16,
        2'b11, rmem >> 24
    });

    ysyx_25040111_MuxKey #(4, 2, 32) c_rdmem(rdata, mask, {
        2'b00, 32'b0,
        2'b01, {{24{offset[7] & sign}}, offset[7:0]},
        2'b10, {{16{offset[15] & sign}}, offset[15:0]},
        2'b11, offset
    });

endmodule
