module ysyx_25040111_idu(
    input [31:0] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm,
    output [4:0] opt
);

    // ------------------------------------------------------- 
    //                         立即数操作                       
    // -------------------------------------------------------
    wire [4:0] rs1_opimm, rd_opimm;
    wire [31:0] imm_opimm;
    wire [4:0] opt_opimm;
    ysyx_25040111_opimm u_ysyx_25040111_opimm(
        .inst 	(inst[31:7]),
        .rs1  	(rs1_opimm ),
        .rd   	(rd_opimm  ),
        .imm  	(imm_opimm ),
        .opt    (opt_opimm)
    );

    // ------------------------------------------------------- 
    //                         System                       
    // -------------------------------------------------------
    ysyx_25040111_system u_ysyx_25040111_system(
        .inst 	(inst[31:0]  )
    );

    ysyx_25040111_MuxKeyWithDefault #(1, 7, 5) rs1_c (rs1, inst[6:0], 5'b0, {
        7'b0010011, rs1_opimm
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 7, 5) rs2_c (rs2, inst[6:0], 5'b0, {
        7'b0010011, 5'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 7, 5) rd_c (rd, inst[6:0], 5'b0, {
        7'b0010011, rd_opimm
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 7, 32) imm_c (imm, inst[6:0], 32'b0, {
        7'b0010011, imm_opimm
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 7, 5) opt_c (opt, inst[6:0], 5'b0, {
        7'b0010011, opt_opimm
    });

endmodule
