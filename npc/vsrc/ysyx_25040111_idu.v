`define OPCODE_NUM 3

module ysyx_25040111_idu(
    input [31:0] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm,
    output [7:0] opt
);

    // ------------------------------------------------------- 
    //                         立即数操作                       
    // -------------------------------------------------------
    wire [4:0] rs1_opimm, rd_opimm;
    wire [31:0] imm_opimm;
    wire [7:0] opt_opimm;

    ysyx_25040111_opimm u_ysyx_25040111_opimm(
        .inst 	(inst[31:7]),
        .rs1  	(rs1_opimm ),
        .rd   	(rd_opimm  ),
        .imm  	(imm_opimm ),
        .opt    (opt_opimm)
    );

    // ------------------------------------------------------- 
    //                         AUIPC                  
    // -------------------------------------------------------
    wire [4:0] rd_auipc;
    wire [31:0] imm_auipc;
    wire [7:0] opt_auipc;

    ysyx_25040111_auipc u_ysyx_25040111_auipc(
        .inst 	(inst[31:7]  ),
        .rd   	(rd_auipc    ),
        .imm  	(imm_auipc   ),
        .opt  	(opt_auipc   )
    );
    
    // ------------------------------------------------------- 
    //                         LUI          
    // -------------------------------------------------------
    wire [4:0] rd_lui;
    wire [31:0] imm_lui;
    wire [7:0] opt_lui;

    ysyx_25040111_lui u_ysyx_25040111_lui(
        .inst 	(inst[31:7]  ),
        .rd   	(rd_lui    ),
        .imm  	(imm_lui   ),
        .opt  	(opt_lui   )
    );

    // ------------------------------------------------------- 
    //                         System                       
    // -------------------------------------------------------
    ysyx_25040111_system u_ysyx_25040111_system(
        .inst 	(inst[31:0]  )
    );


    // ------------------------------------------------------- 
    //                         Choose                       
    // -------------------------------------------------------
    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rs1_c (rs1, inst[6:0], 5'b0, {
        7'b0010011, rs1_opimm,
        7'b0010111, 5'b0,
        7'b0110111, 5'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rs2_c (rs2, inst[6:0], 5'b0, {
        7'b0010011, 5'b0,
        7'b0010111, 5'b0,
        7'b0110111, 5'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rd_c (rd, inst[6:0], 5'b0, {
        7'b0010011, rd_opimm,
        7'b0010111, rd_auipc,
        7'b0110111, rd_lui
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 32) imm_c (imm, inst[6:0], 32'b0, {
        7'b0010011, imm_opimm,
        7'b0010111, imm_auipc,
        7'b0110111, imm_lui
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 8) opt_c (opt, inst[6:0], 8'b0, {
        7'b0010011, opt_opimm,
        7'b0010111, opt_auipc,
        7'b0110111, opt_lui
    });

endmodule
