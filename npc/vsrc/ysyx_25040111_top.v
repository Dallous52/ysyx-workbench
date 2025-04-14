`include "include/ysyx_25040111_tpdef.vh" 

module ysyx_25040111_top(
    input clk,
    input [31:0] inst
    // output reg [31:0] pc
);
   
    wire [31:0] wdata, rdata;
    wire [4:0] waddr, raddr;
    wire wen, gen;

    // 使能设置
    assign gen = inst[0] & inst[1];
    assign wen = gen ? wen : 0;

    wire [31:0] rdata;
    wire [4:0] raddr;
    wire [31:0] tdata;
    wire [4:0] taddr;
    
    ysyx_25040111_opimm u_ysyx_25040111_opimm(
        .inst  	(inst   ),
        .rs1   	(raddr  ),
        .wdata 	(tdata  ),
        .waddr 	(taddr  )
    );

    // 通用寄存器
    ysyx_25040111_RegisterFile #(5, 32) u_RegisterFile (
        .clk   	(clk    ),
        .wen   	(wen    ),
        .wdata 	(wdata  ),
        .waddr 	(waddr  ),
        .raddr 	(raddr  ),
        .rdata 	(rdata  )
    );

    assign wdata = rdata + tdata;
    assign waddr = taddr;

endmodule
