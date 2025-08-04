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
    output reg [31:0] rdata,// 读出数据
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

    reg [3:0] wmask;
    reg [2:0] tsize;

    always @(*) begin
        case (mask)
            2'b00: begin 
                wmask = 4'h0; 
                tsize = 3'b000;
                rdata = 32'b0;
            end
            2'b01: begin 
                wmask = 4'b0001 << addr[1:0];
                tsize = 3'b000; 
                rdata = {{24{offset[7] & sign}}, offset[7:0]};
            end
            2'b10: begin 
                wmask = addr[1] ? 4'b1100 : 4'b0011; 
                tsize = 3'b001;
                rdata = {{16{offset[15] & sign}}, offset[15:0]};    
            end
            2'b11: begin 
                wmask = 4'b1111; 
                tsize = 3'b010;
                rdata = offset;
            end
        endcase
    end

    reg [31:0] wmem;
    always @(*) begin
        case (addr[1:0])
            2'b00: wmem = wdata;
            2'b01: wmem = wdata << 8;
            2'b10: wmem = wdata << 16;
            2'b11: wmem = wdata << 24;
        endcase
    end

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
    assign io_master_arlen    = tlen;
    assign io_master_arsize   = is_clint ? 3'b0 : tsize;
    assign io_master_arburst  = |tlen ? 2'b01 : 2'b00;

    assign io_master_rready   = is_clint ? 1'b0 : rready;

`elsif YOSYS_STA
    assign arready = is_clint ? arready_clint : 0;
    assign rvalid = is_clint ? rvalid_clint : 0;
    assign rresp = is_clint ? rresp_clint : 0;
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
            rmem <= is_clint ? rmem_clint : 
            `ifdef RUNSOC 
                io_master_rdata;
            `elsif YOSYS_STA
                32'b0;
            `else 
                rmem_sram;
            `endif
            valid_t <= 1;
        end
        else if (bready & bvalid) begin
            valid_t <= 1;
        end
        else valid_t <= 0;

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

`ifndef YOSYS_STA
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
`endif

`endif // NOT RUNSOC

    reg [31:0] offset;
    always @(*) begin
        case (addr[1:0])
            2'b00: offset = rmem;
            2'b01: offset = rmem >> 8;
            2'b10: offset = rmem >> 16;
            2'b11: offset = rmem >> 24;
        endcase
    end


endmodule
