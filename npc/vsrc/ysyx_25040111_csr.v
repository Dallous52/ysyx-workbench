module ysyx_25040111_csr(
    input clk,
    input wen,
    input ren,
    input [11:0] waddr,
    input [31:0] wdata,
    input [11:0] raddr,
    input [1:0]  jtype,
    output [31:0] rdata
);

    reg [31:0] csr[3:0];
    wire [11:0] raddr_m;

    initial begin
        csr[0] = 32'h00001800;
        csr[1] = 32'h00000000;
        csr[2] = 32'h00000000;
        csr[3] = 32'h00000000;
    end

    // 写入
    always @(posedge clk) begin
        if (wen) begin
            // $display("waddr: %d, wdata: %h\n", waddr, wdata);
            case (waddr)
                12'h300: csr[0] <= wdata;
                12'h305: csr[1] <= wdata;
                12'h341: csr[2] <= wdata;
                default: ;
            endcase
        end
    end

    // mcause write
    always @(posedge clk) begin
        if (|jtype) begin
            case (jtype)
                2'b01: csr[3] <= 32'd11;
                2'b10: ;
                2'b11: ;
                default: ;
            endcase
        end
    end

    // 读寄存器使能判断
    assign raddr_m = ren ? raddr : {12{1'b0}};

    // MSTATUS	0x300
    // MTVEC	0x305
    // MEPC	    0x341
    // MCAUSE	0x342
    // 读取
    ysyx_25040111_MuxKeyWithDefault #(4, 12, 32) imm_c (rdata, raddr_m, 32'b0, {
        12'h300, csr[0],
        12'h305, csr[1],
        12'h341, csr[2],
        12'h342, csr[3]
    });

endmodule
