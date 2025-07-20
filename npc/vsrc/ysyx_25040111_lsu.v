`include "HDR/ysyx_20540111_dpic.vh"
`include "MOD/ysyx_25040111_MuxKey.v"

`define DEV_CLINT   (32'h02000048)
`define DEV_CLINT_END  (32'h0200004f)

module ysyx_25040111_lsu (
        input clk,          // 时钟
        input ready,
        input wen,          // 写使能
        input ren,          // 读使能
        input sign,         // 有无符号标志
        input [1:0] mask,   // 掩码选择
        input [31:0] addr,  // 内存操作地址
        input [31:0] wdata, // 写入数据
        output [31:0] rdata,// 读出数据
        output valid,

        input io_master_awready,
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
    );

    reg arvalid;
    reg  rready;
    reg awvalid, wvalid;
    reg bready;
    wire [1:0] rresp;
    reg arready, awready;
    reg rvalid;
    reg wready, wlast;
    wire bvalid;
    wire [1:0] bresp;
    reg [31:0] rmem;

    wire arvalid_clint, rready_clint;
    wire [1:0] rresp_clint;
    wire arready_clint, awready_clint;
    wire rvalid_clint;
    wire wready_clint;
    wire bvalid_clint;
    wire [1:0] bresp_clint;
    reg [31:0] rmem_clint;

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

    wire is_clint;
    assign is_clint = (addr >= `DEV_CLINT && addr <= `DEV_CLINT_END);

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

    reg valid_t;
    // memory read
    assign rready = 1;
    always @(posedge clk) begin
        // $display("rmem = %h", rmem);
        // $display("is_clint:%b  arvalid:%b  arready:%b", is_clint, arvalid, io_master_arready);
        // $display("rvalid:%b  rready:%b  rresp:%h", io_master_rvalid, rready, rresp);
        
        // 地址有效
        if (ren & ready)
            arvalid <= 1;

        if (arvalid & arready)
            arvalid <= 0;

        // 读取数据
        // if (rvalid)
        //     rready <= 1;

        if (rvalid & rready) begin
            valid_t <= 1;
            rmem <= is_clint ? rmem_clint : io_master_rdata;
            // rready <= 0;
            if (addr >= 32'ha000_0000 & addr <= 32'ha001_0000)
                $display("raddr:%h  rdata:%h", addr, io_master_rdata);
        end
    end

    // memory write
    assign bready = 1;
    always @(posedge clk) begin
        // 地址有效
        if (wen & ready)
            awvalid <= 1;

        if (awvalid & awready) begin
            awvalid <= 0;
            wvalid <= 1;
        end

        // 写入参数
        if (wvalid & wready) begin
            if (addr >= 32'ha000_0000 & addr <= 32'ha001_0000) 
                $display("waddr:%h  wdata:%h", addr, io_master_wdata);
            wvalid <= 0;
            wlast <= 1;
        end
        else
            wlast <= 0;

        // if (bvalid)
        //     bready <= 1;

        // 写回复信息
        if (bready & bvalid) begin
            bready <= 0;
            valid_t <= 1;
        end
    end

    always @(posedge clk) begin
        if (valid_t)
            valid_t <= 0;

        if (|rresp | |bresp)
            ebreak(5);
    end

    assign valid = wen | ren ? valid_t : ready;

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

    // always @(*) begin
    //     if (addr >= `DEV_CLINT && addr <= `DEV_CLINT_END) begin
    //         arvalid_clint = arvalid;
    //         arready = arready_clint;
    //         rresp = rresp_clint;
    //         rvalid = rvalid_clint;
    //         rready_clint = rready;
    //         rmem = rmem_clint;
    //     end
    //     else begin
    //         arvalid_clint = 0;

    //         awready = io_master_awready;
    //         io_master_awvalid = awvalid;
    //         io_master_awaddr = addr;
    //         io_master_awid = 0;
    //         io_master_awlen = 0;
    //         io_master_awsize = tsize;
    //         io_master_awburst = 0;

    //         wready = io_master_wready;
    //         io_master_wvalid = wvalid;
    //         io_master_wdata = wmem;
    //         io_master_wstrb = wmask;
    //         io_master_wlast = wlast;

    //         io_master_bready = bready;
    //         bvalid = io_master_bvalid;
    //         bresp = io_master_bresp;

    //         arready = io_master_arready;
    //         io_master_arvalid = arvalid;
    //         io_master_araddr = addr;
    //         io_master_arid = 0;
    //         io_master_arlen = 0;
    //         io_master_arsize = tsize;
    //         io_master_arburst = 0;

    //         io_master_rready = rready;
    //         rvalid = io_master_rvalid;
    //         rresp = io_master_rresp;
    //         rmem = io_master_rdata;
    //     end
    // end
