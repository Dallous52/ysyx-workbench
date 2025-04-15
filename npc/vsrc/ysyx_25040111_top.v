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
    wire [4:0] opt;
    
    ysyx_25040111_idu u_idu(
        .en   	(inst[0] & inst[1]),
        .clk  	(clk    ),
        .inst 	(inst[31:2]),
        .rs1  	(rs1   ),
        .rs2  	(rs2   ),
        .rd   	(rd    ),
        .imm  	(imm   ),
        .opt  	(opt   )
    );

    wire [31:0] rs1_d, rs2_d, rd_d;
    wire wen;
    wire [1:0] ren;

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 1) wen_c (wen, opt, 1'b0, {
        5'b00001, 1'b1
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 2) ren_c (ren, opt, 2'b0, {
        5'b00001, 2'b01
    });

    ysyx_25040111_RegisterFile #(5, 32) u_RegisterFile(
        .clk   	(clk    ),
        .wen   	(wen    ),
        .ren   	(ren    ),
        .wdata 	(rd_d  ),
        .waddr 	(rd ),
        .raddr 	({rs2, rs1}  ),
        .rdata 	({rs2_d, rs1_d}  )
    );
    
    
    ysyx_25040111_exu u_ysyx_25040111_exu(
        .clk   	(clk    ),
        .opt   	(opt    ),
        .rs1_d 	(rs1_d  ),
        .rs2_d 	(rs2_d  ),
        .imm   	(imm    ),
        .rd_d  	(rd_d   )
    );
    
    
    ysyx_25040111_Reg #(32, 32'h80000000) u_ysyx_25040111_Reg(
        .clk  	(clk   ),
        .rst  	(rst   ),
        .din  	(pc + 32'd4),
        .dout 	(pc  ),
        .wen  	(wen   )
    );
    
   
endmodule
