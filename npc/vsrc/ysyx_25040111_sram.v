`include "HDR/ysyx_20540111_dpic.vh"

`define READ_TIME 5'd1

module ysyx_25040111_sram(
    input clk,
    input [31:0] araddr,
    input arvalid,
    output reg arready,

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
    reg rdstart;
    reg [4:0] count;
    reg [31:0] rdata_t;

    assign arready = 1;
    always @(posedge clk) begin
        // 地址读取
        // if (arvalid) arready <= 1;

        // 准备开始
        if (arvalid & arready) begin
            arready <= 0;
            rdstart <= 1;
            rvalid <= 0;
            count <= 5'b0;
        end

        // 数据读取
        if (rdstart) begin
            if (count == `READ_TIME) begin
                rdata_t <= pmem_read(araddr);
                rvalid <= 1; // 读取完毕
                rdstart <= 0;            
            end
            else count <= count + 1;    
        end
        
        // 完成传输
        if (rvalid & rready) begin
            rdata <= rdata_t;
            rresp <= 2'b00;
            rvalid <= 0;            
        end
    end


    // memory write
    reg wtstart;
    wire [7:0] wmask;
    assign wmask = {4'b0, wstrb};

    always @(posedge clk) begin
        // 地址读取
        if (awvalid) awready <= 1;

        // 写入参数读取准备
        if (awvalid & awready) begin
           awready <= 0;
           wtstart <= 1;
        end

        if (wtstart & wvalid) begin
            if (count == `READ_TIME) begin
                pmem_write(awaddr, wdata, wmask);
                wready <= 1;
                wtstart <= 0;       
            end
            else count <= count + 1;   
        end

        // 读取结束
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
