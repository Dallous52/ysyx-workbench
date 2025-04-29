`define OPCODE_NUM 6

module ysyx_25040111_idu(
    input [31:0] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm,
    output [9:0] opt
);

    // ------------------------------------------------------- 
    //                         OP-IMM                      
    // -------------------------------------------------------
    wire [4:0] rs1_opimm, rd_opimm;
    wire [31:0] imm_opimm;
    wire [9:0] opt_opimm;

    ysyx_25040111_opimm u_ysyx_25040111_opimm(
        .inst 	(inst[31:7]),
        .rs1  	(rs1_opimm ),
        .rd   	(rd_opimm  ),
        .imm  	(imm_opimm ),
        .opt    (opt_opimm)
    );


    // ------------------------------------------------------- 
    //                  AUIPC        LUI              
    // -------------------------------------------------------
    wire [4:0] rd_auipc_lui;
    wire [31:0] imm_auipc_lui;
    wire [9:0] opt_auipc_lui;
    
    ysyx_25040111_auipc_lui u_ysyx_25040111_auipc_lui(
        .inst 	(inst[31:7]  ),
        .chos 	(inst[5]  ),
        .rd   	(rd_auipc_lui    ),
        .imm  	(imm_auipc_lui   ),
        .opt  	(opt_auipc_lui   )
    );


    // ------------------------------------------------------- 
    //                          JALR             
    // -------------------------------------------------------
    wire [4:0] rs1_jalr;
    wire [31:0] imm_jalr;
    wire [9:0] opt_jalr;
    wire [4:0] rd_jalr;
    
    ysyx_25040111_jalr u_ysyx_25040111_jalr(
        .inst 	(inst[31:7]  ),
        .rs1  	(rs1_jalr   ),
        .imm  	(imm_jalr   ),
        .opt  	(opt_jalr   ),
        .rd   	(rd_jalr    )
    );


    // ------------------------------------------------------- 
    //                         JAL                     
    // -------------------------------------------------------
    wire [31:0] imm_jal;
    wire [9:0] opt_jal;
    wire [4:0] rd_jal;
    
    ysyx_25040111_jal u_ysyx_25040111_jal(
        .inst 	(inst[31:7]  ),
        .imm  	(imm_jal   ),
        .opt  	(opt_jal   ),
        .rd   	(rd_jal    )
    );
    

    // ------------------------------------------------------- 
    //                         SYSTEM                       
    // -------------------------------------------------------
    wire [4:0] rs1_system;
    wire [9:0] opt_system;

    ysyx_25040111_system u_ysyx_25040111_system(
        .inst 	(inst[31:0]  ),
        .rs1    (rs1_system),
        .opt    (opt_system)
    );


    // ------------------------------------------------------- 
    //                         Choose                       
    // -------------------------------------------------------
    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rs1_c (rs1, inst[6:0], 5'b0, {
        7'b0010011, rs1_opimm,
        7'b0010111, 5'b0,
        7'b0110111, 5'b0,
        7'b1100111, rs1_jalr,
        7'b1101111, 5'b0,
        7'b1110011, rs1_system
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rs2_c (rs2, inst[6:0], 5'b0, {
        7'b0010011, 5'b0,
        7'b0010111, 5'b0,
        7'b0110111, 5'b0,
        7'b1100111, 5'b0,
        7'b1101111, 5'b0,
        7'b1110011, 5'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rd_c (rd, inst[6:0], 5'b0, {
        7'b0010011, rd_opimm,
        7'b0010111, rd_auipc_lui,
        7'b0110111, rd_auipc_lui,
        7'b1100111, rd_jalr,
        7'b1101111, rd_jal,
        7'b1110011, 5'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 32) imm_c (imm, inst[6:0], 32'b0, {
        7'b0010011, imm_opimm,
        7'b0010111, imm_auipc_lui,
        7'b0110111, imm_auipc_lui,
        7'b1100111, imm_jalr,
        7'b1101111, imm_jal,
        7'b1110011, 32'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 10) opt_c (opt, inst[6:0], 10'b0, {
        7'b0010011, opt_opimm,
        7'b0010111, opt_auipc_lui,
        7'b0110111, opt_auipc_lui,
        7'b1100111, opt_jalr,
        7'b1101111, opt_jal,
        7'b1110011, opt_system
    });

endmodule
