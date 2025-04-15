module ysyx_25040111_idu(
    input en,
    input clk,
    input [31:2] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm,
    output [4:0] opt
);

    wire [4:0] rs1_t, rs2_t, rd_t;
    wire [31:0] imm_t;
    wire [4:0] opt_t;


    wire [4:0] rs1_opimm, rd_opimm;
    wire [31:0] imm_opimm;
    wire [4:0] opt_opimm;
    ysyx_25040111_opimm u_ysyx_25040111_opimm(
        .en   	(inst[6:2] == 5'b00100),
        .clk    (clk),
        .inst 	(inst[31:7]),
        .rs1  	(rs1_opimm ),
        .rd   	(rd_opimm  ),
        .imm  	(imm_opimm ),
        .opt    (opt_opimm)
    );
    

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 5) rs1_c (rs1_t, inst[6:2], 5'b0, {
        5'b00100, rs1_opimm
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 5) rs2_c (rs2_t, inst[6:2], 5'b0, {
        5'b00100, 5'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 5) rd_c (rd_t, inst[6:2], 5'b0, {
        5'b00100, rd_opimm
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 32) imm_c (imm_t, inst[6:2], 32'b0, {
        5'b00100, imm_opimm
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 5) opt_c (opt_t, inst[6:2], 5'b0, {
        5'b00100, opt_opimm
    });

    ysyx_25040111_Reg #(5, 0) rs1_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(rs1_t  ),
        .dout 	(rs1  ),
        .wen  	(en   )
    );

    ysyx_25040111_Reg #(5, 0) rs2_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(rs2_t),
        .dout 	(rs2  ),
        .wen  	(en   )
    );

    ysyx_25040111_Reg #(5, 0) rd_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(rd_t),
        .dout 	(rd  ),
        .wen  	(en   )
    );
    
    ysyx_25040111_Reg #(32, 0) imm_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(imm_t),
        .dout 	(imm  ),
        .wen  	(en   )
    );

    ysyx_25040111_Reg #(5, 0) opt_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(opt_t),
        .dout 	(opt  ),
        .wen  	(en   )
    );

endmodule
