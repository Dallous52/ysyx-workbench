// OPT [4:0]
//      [0]: reg wirte en (write to rd)
//      [2:1]: reg read en [rs2, rs1]
//      [4:3]: alu arguments
//              00  pc, imm
//              01  rs1, rs2
//              10  rs1, imm
//              11  rs1, shame[rs2]
//      [7:5]: alu option
//              000 empty
//              001 add
//              010 and
//              011 or
//              100 xor
//              101 shift


module ysyx_25040111_top(
    input clk,
    input rst,
    input [31:0] inst,
    output [31:0] pc
);
   
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [31:0] imm;
    wire [7:0] opt;
    
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
        .rdata 	({rs2_d, rs1_d}  )
    );
    
    
    ysyx_25040111_exu u_ysyx_25040111_exu(
        .opt   	(opt[7:3]    ),
        .rs1_d 	(rs1_d  ),
        .rs2_d 	(rs2_d  ),
        .imm   	(imm    ),
        .pc     (pc),
        .rd_d  	(rd_d   )
    );
    
    
    ysyx_25040111_Reg #(32, 32'h80000000) u_ysyx_25040111_Reg(
        .clk  	(clk   ),
        .rst  	(rst   ),
        .din  	(pc + 32'd4),
        .dout 	(pc  ),
        .wen  	(1   )
    );
    
   
endmodule
