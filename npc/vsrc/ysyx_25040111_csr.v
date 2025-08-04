module ysyx_25040111_csr(
    input clk,
    input wen,
    input ren,
    input reset,
    input [11:0] waddr,
    input [31:0] wdata,
    input [11:0] raddr,
    input [1:0]  jtype,
    output reg [31:0] rdata
);

    reg [31:0] csr[3:0];
    wire [31:0] marchid = 32'd25040111;
    wire [31:0] mvendorid = 32'h79737978;

    // 写入
    always @(posedge clk) begin
        if (reset) begin
            csr[0] <= 32'h00001800;
            csr[1] <= 32'h00000000;
            csr[2] <= 32'h00000000;
            csr[3] <= 32'h00000000;
        end
        else if (wen) begin
            if (waddr == 12'h300)
                csr[0] <= wdata;
            else if (waddr == 12'h305)
                csr[1] <= wdata;
            else if (waddr == 12'h341)
                csr[2] <= wdata;
        end
        else if (jtype == 2'b01) begin
            csr[3] <= 32'd11;   // ecall
        end
    end

    // MSTATUS	0x300
    // MTVEC	0x305
    // MEPC	    0x341
    // MCAUSE	0x342
    // 读取
    always @(*) begin
        if (ren) begin
            case (raddr)
                12'h300: rdata = csr[0];
                12'h305: rdata = csr[1];
                12'h341: rdata = csr[2];
                12'h342: rdata = csr[3];
                12'hF11: rdata = mvendorid;
                12'hF12: rdata = marchid;
                default: rdata = marchid;
            endcase
        end
        else
            rdata = 32'b0;
    end

endmodule
