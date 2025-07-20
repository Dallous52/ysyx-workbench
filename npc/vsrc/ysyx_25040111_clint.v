module ysyx_25040111_clint(
        input clk,
        input [31:0] araddr,
        input arvalid,
        output reg arready,

        output reg [31:0] rdata,
        output [1:0] rresp,
        output rvalid,
        input rready
    );

    // memory read
    reg rdstart;
    reg [31:0] rdata_t;
    reg [63:0] mtime;

    always @(posedge clk) begin
        mtime <= mtime + 1;

        // 地址读取
        if (arvalid)
            arready <= 1;

        // 准备开始
        if (arvalid & arready) begin
            arready <= 0;
            rdstart <= 1;
            rvalid <= 0;
        end

        // 数据读取
        if (rdstart) begin
            rdata_t <= araddr == 32'h02000048 ? mtime[31:0] : mtime[63:32];
            rvalid <= 1; // 读取完毕
            rdstart <= 0;
        end

        // 完成传输
        if (rvalid & rready) begin
            rdata <= rdata_t;
            rresp <= 2'b00;
            rvalid <= 0;
        end
    end

endmodule
