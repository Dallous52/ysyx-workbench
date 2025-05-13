`include "ysyx_25040111_inc.vh"

module ysyx_25040111_store(
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [31:0] imm,
    output [`OPT_HIGH:0] opt
);

    wire [11:0] imm_m;
    wire [2:0] fun3;

    assign imm_m[11:5] = inst[31:25];
    assign imm_m[4:0] = inst[11:7];
    assign fun3 = inst[14:12];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];

    assign imm = {{20{imm_m[11]}}, imm_m};

    ysyx_25040111_MuxKeyWithDefault #(3, 3, `OPT_LEN) opt_c (opt, fun3, `OPT_LEN'b0, {
        3'b010, `OPTG(`XFS, `RF_IM, `ADD, `SNPC, `MSW, `EMPTY),  // sw
        3'b001, `OPTG(`XFS, `RF_IM, `ADD, `SNPC, `MSH, `EMPTY),  // sh
        3'b000, `OPTG(`XFS, `RF_IM, `ADD, `SNPC, `MSB, `EMPTY)   // sh
    });

endmodule
