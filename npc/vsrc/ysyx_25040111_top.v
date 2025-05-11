// OPT [15:0]
//      [0]: reg wirte en (write to rd)
//      [2:1]: reg read en [rs2, rs1]
//      [4:3]: alu arguments
//              00  empty
//              01  pc, imm
//              10  rs1, rs2
//              11  rs1, imm
//      [7:5]: alu option
//              000 empty
//              001 add
//              010 and
//              011 or
//              100 xor
//              101 shift
//              110 pc + 4 (static next pc)
//      [9:8]: pc update option
//              00 empty
//              01 pc + 4
//              10 pc + imm
//              11 rs1 + imm
//      [12:10] memory control option
//              000 empty
//              001 sb
//              010 sh
//              011 sw
//              101 lb
//              110 lh
//              111 lw
//      [13]    shame enable
//      [14]    unsigned enable
//      [15]    other option

`include "ysyx_25040111_inc.vh" 

module ysyx_25040111_top(
    input clk,
    input rst,
    output reg [31:0] inst,
    output [31:0] pc
);
   
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [31:0] imm;
    wire [`OPT_HIGH:0] opt;

    always @(*) begin
        inst = pmem_read(pc);
    end

    ysyx_25040111_idu u_idu(
        .inst 	(inst[31:0]),
        .rs1  	(rs1   ),
        .rs2  	(rs2   ),
        .rd   	(rd    ),
        .imm  	(imm   ),
        .opt  	(opt   )
    );

    wire [31:0] rs1_d, rs2_d, rd_d;

    ysyx_25040111_RegisterFile #(5, 32) u_RegisterFile(
        .clk   	(clk    ),
        .wen   	(opt[0]    ),
        .ren   	(opt[2:1]  ),
        .wdata 	(rd_d  ),
        .waddr 	(rd ),
        .raddr 	({rs2, rs1}  ),
        .rdata 	({rs2_d, rs1_d} )
    );
    
    wire [31:0] dnpc;
    ysyx_25040111_exu u_ysyx_25040111_exu(
        .opt   	(opt    ),
        .rs1_d 	(rs1_d  ),
        .rs2_d 	(rs2_d  ),
        .imm   	(imm    ),
        .pc     (pc),
        .rd_d  	(rd_d   ),
        .dnpc   (dnpc)
    );
    
    
    ysyx_25040111_Reg #(32, 32'h80000000) u_ysyx_25040111_Reg(
        .clk  	(clk   ),
        .rst  	(rst   ),
        .din  	(dnpc),
        .dout 	(pc  ),
        .wen  	(1   )
    );

endmodule
