`include "HDR/ysyx_20540111_dpic.vh"
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
    output [31:0] rdata,// 读出数据
    output reg valid
);

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

    // always @(*) begin
    //     if (ready & wen) begin
    //         pmem_write(addr, wmem, wmask);          
    //     end
    // end

    // reg [31:0] rmem;
    // reg valid_t;
    // always @(posedge clk) begin
    //     if (ren) begin
    //         if (ready) begin
    //             rmem <= pmem_read(addr);
    //             valid_t <= 1;                
    //         end
    //         else
    //             rmem <= rmem;
    //     end
    //     else 
    //         rmem <= 32'b0;

    //     if (valid_t)
    //         valid_t <= 0;
    // end
    
    // assign valid = ren ? valid_t : ready;

    // output declaration of module ysyx_25040111_sram
    reg [31:0] rmem;
    wire [1:0] rresp;
    reg rvalid, arvalid;
    reg arready, rready;
    wire [1:0] bresp;
    wire bvalid;
    reg awvalid, wvalid;
    reg awready, wready;
    reg bready;

    // memory read
    always @(posedge clk) begin
        // 地址有效
        if (ren & ready)
            arvalid <= 1;
        
        if (arvalid & arready)
            arvalid <= 0;

        // 读取数据
        if (rvalid) rready <= 1;

        if (rvalid & rready) begin
            valid <= 1;
            rready <= 0;            
        end
    end

    // memory write
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

        if (bready & bvalid) begin 
            bready <= 0;
            valid <= 1;
        end
    end

    always @(posedge clk) begin
        if (valid) valid <= 0;
    end
    
    ysyx_25040111_sram u_ysyx_25040111_sram(
        .clk     	(clk      ),
        .araddr  	(addr   ),
        .arvalid 	(arvalid),
        .arready 	(arready  ),
        .rdata   	(rmem    ),
        .rresp   	(rresp    ),
        .rvalid  	(rvalid   ),
        .rready  	(rready   ),
        .awaddr  	(addr   ),
        .awvalid 	(awvalid  ),
        .awready 	(awready  ),
        .wdata   	(wmem    ),
        .wstrb   	(wmask[3:0]),
        .wvalid  	(wvalid   ),
        .wready  	(wready   ),
        .bresp   	(bresp    ),
        .bvalid  	(bvalid   ),
        .bready  	(bready   )
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
