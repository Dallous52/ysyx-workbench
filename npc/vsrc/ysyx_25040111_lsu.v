`include "HDR/ysyx_20540111_dpic.vh"
`include "MOD/ysyx_25040111_MuxKey.v"

module ysyx_25040111_lsu (
    input wen,          // 写使能
    input ren,          // 读使能 
    input sign,         // 有无符号标志
    input [1:0] mask,   // 掩码选择
    input [31:0] addr,  // 内存操作地址
    input [31:0] wdata, // 写入数据
    output [31:0] rdata // 读出数据
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

    always @(*) begin
        if (wen)
            pmem_write(addr, wdata, wmask);
    end

    reg [31:0] rmem;
    always @(*) begin
        if (ren) begin
            rmem = pmem_read(addr);
            $display("addr:%h rmem: %h  rdata: %h", addr, rmem, rdata);
        end
        else 
            rmem = 32'b0;
    end

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
