`ifndef YOSYS_STA

`include "HDR/ysyx_20540111_dpic.vh"
// `include "MOD/ysyx_25040111_RegisterFile.v"

`define READY_TIME 8'd1

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

    // LFSP 随机数发生器
    // reg [7:0] nums;

    // memory read
    reg rdstart;
    reg [7:0] count;
    reg [31:0] rdata_t;

    // assign arready = 1;
    always @(posedge clk) begin
        // 地址读取
        if (arvalid) arready <= 1;

        // LFSP INIT
        // if (~|nums) nums <= 8'b00000001;

        // 准备开始
        if (arvalid & arready) begin
            arready <= 0;
            rdstart <= 1;
            rvalid <= 0;
            count <= 8'b0;

            // LFSP UPDATE
            // nums <= {^nums[4:2] ^ nums[0], nums[7:1]};
        end

        // 数据读取
        if (rdstart) begin
            if (count == `READY_TIME) begin // nums) begin
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

    // ysyx_25040111_RegisterFile #(8, 32) u_rom2_t(
    //     .clk   	(clk    ),
    //     .wen   	(wtstart & wvalid & (count == `READY_TIME)),
    //     .ren   	({rdstart & (count == `READY_TIME), 1'b0}),
    //     .wdata 	(wdata),
    //     .waddr 	(awaddr[7:0]),
    //     .raddr1 (araddr[7:0]),
    //     .rdata1 (rdata_t)
    // );

    // memory write
    reg wtstart;
    wire [7:0] wmask;
    assign wmask = {4'b0, wstrb};

    // assign awready = 1;
    // assign wready = 1;
    always @(posedge clk) begin
        // 地址读取
        if (awvalid) awready <= 1;

        // 写入参数读取准备
        if (awvalid & awready) begin
            awready <= 0;
            wtstart <= 1;

            // LFSP UPDATE
            // nums <= {^nums[4:2] ^ nums[0], nums[7:1]};
        end

        if (wtstart & wvalid) begin
            if (count == `READY_TIME) begin
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

`endif // YOSYS_STA
