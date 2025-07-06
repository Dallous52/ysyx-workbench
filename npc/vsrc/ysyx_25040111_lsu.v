`include "HDR/ysyx_20540111_dpic.vh"
`include "MOD/ysyx_25040111_MuxKey.v"

`define DEV_SERIAL  (32'ha00003f8)
`define DEV_TIMER   (32'ha0000048)
`define DEV_TIMER_END  (32'ha000004f)


`define DEVICE_MODULE(dev, num) \
    wire [31:0] rmem_``dev; \
    wire [1:0] rresp_``dev; \
    wire arready_``dev, awready_``dev; \
    wire rvalid_``dev; \
    wire wready_``dev; \
    wire bvalid_``dev; \
    wire [1:0] bresp_``dev; \
    ysyx_25040111_``dev u_ysyx_25040111_``dev( \
        .clk     	(clk), \
        .araddr  	(addr), \
        .arvalid 	(Xbar[num] ? arvalid : 0), \
        .arready 	(Xbar[num] ? arready : arready_``dev), \
        .rdata   	(Xbar[num] ? rmem : rmem_``dev), \
        .rresp   	(Xbar[num] ? rresp : rresp_``dev), \
        .rvalid  	(Xbar[num] ? rvalid : rvalid_``dev), \
        .rready  	(rready   ), \
        .awaddr  	(addr   ), \
        .awvalid 	(Xbar[num] ? awvalid : 0), \
        .awready 	(Xbar[num] ? awready : awready_``dev), \
        .wdata   	(wmem    ), \
        .wstrb   	(wmask[3:0]), \
        .wvalid  	(wvalid   ), \
        .wready  	(Xbar[num] ? wready : wready_``dev), \
        .bresp   	(Xbar[num] ? bresp : bresp_``dev), \
        .bvalid  	(Xbar[num] ? bvalid : bvalid_``dev), \
        .bready  	(bready   ) \
    )

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
    output valid
);

    reg [2:0] Xbar;
    always @(*) begin
        if (addr == `DEV_SERIAL)
            Xbar = 3'b010;
        else if (addr >= `DEV_TIMER && addr <= `DEV_TIMER_END)
            Xbar = 3'b100;
        else 
            Xbar = 3'b001;
    end

    wire [7:0] wmask;    
    ysyx_25040111_MuxKey #(4, 2, 8) c_wmask(wmask, mask, {
        2'b00, 8'h00,
        2'b01, 8'b00000001 << addr[1:0],
        2'b10, addr[1] ? 8'b00001100 : 8'b00000011,
        2'b11, 8'b00001111
    });

    wire [31:0] wmem;
    ysyx_25040111_MuxKey #(4, 2, 32) c_wt_data(wmem, addr[1:0], {
        2'b00, wdata,
        2'b01, wdata << 8,
        2'b10, wdata << 16,
        2'b11, wdata << 24
    });

    // output declaration of module ysyx_25040111_sram
    reg arvalid;
    reg  rready;
    reg awvalid, wvalid;
    reg bready;

    reg [31:0] rmem;
    wire [1:0] rresp;
    reg arready, awready;
    reg rvalid;
    reg wready;
    wire bvalid;
    wire [1:0] bresp;

    reg valid_t;
    // memory read
    // assign rready = 1;
    always @(posedge clk) begin
        // 地址有效
        if (ren & ready)
            arvalid <= 1;
        
        if (arvalid & arready)
            arvalid <= 0;

        // 读取数据
        if (rvalid) rready <= 1;
        
        if (rvalid & rready) begin
            valid_t <= 1;
            rready <= 0;            
        end
    end

    // memory write
    // assign bready = 1;
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
            wvalid <= 0;           
        end

        if (bvalid) bready <= 1;

        // 写回复信息
        if (bready & bvalid) begin
            bready <= 0;
            valid_t <= 1;
        end
    end

    always @(posedge clk) begin
        if (valid_t) valid_t <= 0;
    end
    
    assign valid = wen | ren ? valid_t : ready;

    `DEVICE_MODULE(sram, 0);
    `DEVICE_MODULE(uart, 1);
    // `DEVICE_MODULE(clint, 2);

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
