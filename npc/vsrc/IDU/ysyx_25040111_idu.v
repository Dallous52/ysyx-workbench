`ifndef NPC_IDU
`define NPC_IDU

`include "../HDR/ysyx_25040111_inc.vh"
`include "../HDR/ysyx_20540111_dpic.vh"

`define OPCODE_NUM 10

module ysyx_25040111_idu(
    input [31:0] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [31:0] imm,
    output [`OPT_HIGH:0] opt,
    output [11:0] csr1, csr2
);

    // -------------------------------------------------------
    //                         OP-IMM                      
    // -------------------------------------------------------
    wire [4:0] rs1_opimm, rd_opimm;
    wire [31:0] imm_opimm;
    wire [`OPT_HIGH:0] opt_opimm;

    ysyx_25040111_opimm u_ysyx_25040111_opimm(
        .inst 	(inst[31:7]),
        .rs1  	(rs1_opimm ),
        .rd   	(rd_opimm  ),
        .imm  	(imm_opimm ),
        .opt    (opt_opimm)
    );


    // ------------------------------------------------------- 
    //                         OP                      
    // -------------------------------------------------------
    wire [4:0] rs1_op, rd_op, rs2_op;
    wire [`OPT_HIGH:0] opt_op;

    ysyx_25040111_op u_ysyx_25040111_op(
        .inst 	(inst[31:7]),
        .rs1  	(rs1_op ),
        .rs2    (rs2_op),
        .rd   	(rd_op ),
        .opt    (opt_op)
    );


    // ------------------------------------------------------- 
    //                  AUIPC        LUI              
    // -------------------------------------------------------
    wire [4:0] rd_auipc_lui;
    wire [31:0] imm_auipc_lui;
    wire [`OPT_HIGH:0] opt_auipc_lui;
    
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
    wire [`OPT_HIGH:0] opt_jalr;
    wire [4:0] rd_jalr;
    
    ysyx_25040111_jalr u_ysyx_25040111_jalr(
        .inst 	(inst[31:7]  ),
        .rs1  	(rs1_jalr   ),
        .imm  	(imm_jalr   ),
        .opt  	(opt_jalr   ),
        .rd   	(rd_jalr    )
    );


    // ------------------------------------------------------- 
    //                          JALR             
    // -------------------------------------------------------
    wire [4:0] rs1_branch;
    wire [4:0] rs2_branch;
    wire [31:0] imm_branch;
    wire [`OPT_HIGH:0] opt_branch;
    
    ysyx_25040111_branch u_ysyx_25040111_branch(
        .inst 	(inst[31:7]  ),
        .rs1  	(rs1_branch   ),
        .rs2  	(rs2_branch   ),
        .imm  	(imm_branch   ),
        .opt  	(opt_branch   )
    );
    


    // ------------------------------------------------------- 
    //                         STORE
    // -------------------------------------------------------
    wire [4:0] rs1_store;
    wire [4:0] rs2_store;
    wire [31:0] imm_store;
    wire [`OPT_HIGH:0] opt_store;
    
    ysyx_25040111_store u_ysyx_25040111_store(
        .inst 	(inst[31:7]  ),
        .rs1  	(rs1_store   ),
        .rs2  	(rs2_store   ),
        .imm  	(imm_store   ),
        .opt  	(opt_store   )
    );
    

    // ------------------------------------------------------- 
    //                         LOAD
    // -------------------------------------------------------
    wire [4:0] rs1_load;
    wire [4:0] rd_load;
    wire [31:0] imm_load;
    wire [`OPT_HIGH:0] opt_load;
    
    ysyx_25040111_load u_ysyx_25040111_load(
        .inst 	(inst[31:7]  ),
        .rs1  	(rs1_load   ),
        .rd   	(rd_load    ),
        .imm  	(imm_load   ),
        .opt  	(opt_load   )
    );
    

    // ------------------------------------------------------- 
    //                         JAL                     
    // -------------------------------------------------------
    wire [31:0] imm_jal;
    wire [`OPT_HIGH:0] opt_jal;
    wire [4:0] rd_jal;
    
    ysyx_25040111_jal u_ysyx_25040111_jal (
        .inst 	(inst[31:7]  ),
        .imm  	(imm_jal     ),
        .opt  	(opt_jal     ),
        .rd   	(rd_jal      )
    );
    

    // ------------------------------------------------------- 
    //                         SYSTEM                       
    // -------------------------------------------------------
    wire [4:0] rs1_system, rd_system;
    wire [`OPT_HIGH:0] opt_system;
    wire [31:0] imm_system;

    ysyx_25040111_system u_ysyx_25040111_system(
        .inst 	(inst[31:7]  ),
        .rs1    (rs1_system),
        .rd     (rd_system),
        .csr2   (csr2),
        .csr1   (csr1),
        .imm    (imm_system),
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
        7'b1110011, rs1_system,
        7'b0100011, rs1_store,
        7'b0000011, rs1_load,
        7'b0110011, rs1_op,
        7'b1100011, rs1_branch
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rs2_c (rs2, inst[6:0], 5'b0, {
        7'b0010011, 5'b0,
        7'b0010111, 5'b0,
        7'b0110111, 5'b0,
        7'b1100111, 5'b0,
        7'b1101111, 5'b0,
        7'b1110011, 5'b0,
        7'b0100011, rs2_store,
        7'b0000011, 5'b0,
        7'b0110011, rs2_op,
        7'b1100011, rs2_branch
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 5) rd_c (rd, inst[6:0], 5'b0, {
        7'b0010011, rd_opimm,
        7'b0010111, rd_auipc_lui,
        7'b0110111, rd_auipc_lui,
        7'b1100111, rd_jalr,
        7'b1101111, rd_jal,
        7'b1110011, rd_system,
        7'b0100011, 5'b0,
        7'b0000011, rd_load,
        7'b0110011, rd_op,
        7'b1100011, 5'b0
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, 32) imm_c (imm, inst[6:0], 32'b0, {
        7'b0010011, imm_opimm,
        7'b0010111, imm_auipc_lui,
        7'b0110111, imm_auipc_lui,
        7'b1100111, imm_jalr,
        7'b1101111, imm_jal,
        7'b1110011, imm_system,
        7'b0100011, imm_store,
        7'b0000011, imm_load,
        7'b0110011, 32'b0,
        7'b1100011, imm_branch
    });

    ysyx_25040111_MuxKeyWithDefault #(`OPCODE_NUM, 7, `OPT_LEN) opt_c (opt, inst[6:0], `OPT_LEN'b0, {
        7'b0010011, opt_opimm,
        7'b0010111, opt_auipc_lui,
        7'b0110111, opt_auipc_lui,
        7'b1100111, opt_jalr,
        7'b1101111, opt_jal,
        7'b1110011, opt_system,
        7'b0100011, opt_store,
        7'b0000011, opt_load,
        7'b0110011, opt_op,
        7'b1100011, opt_branch
    });

`ifdef PMC_EN
    always @(*) begin
        case (inst[6:0])
        7'b0010011: monitor_counter(`IOPT);            
        7'b0010111: monitor_counter(`IOPT);            
        7'b0110111: monitor_counter(`IOPT);            
        7'b1100111: monitor_counter(`IJUMP);            
        7'b1101111: monitor_counter(`IJUMP);            
        7'b1110011: monitor_counter(`ICSR);            
        7'b0100011: monitor_counter(`ISTORE);            
        7'b0000011: monitor_counter(`ILOAD);            
        7'b0110011: monitor_counter(`IOPT);            
        7'b1100011: monitor_counter(`IJUMP);            
        default: ;
        endcase
    end
`endif

endmodule

`endif
