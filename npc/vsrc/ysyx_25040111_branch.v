`include "ysyx_25040111_inc.vh"

module ysyx_25040111_branch(
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [31:0] imm,
    output [`OPT_HIGH:0] opt
);

    wire [12:0] imm_m;
    wire [2:0] fun3;

    assign imm_m[12] = inst[31];
    assign imm_m[10:5] = inst[30:25];
    assign imm_m[4:1] = inst[11:8];
    assign imm_m[11] = inst[7];
    assign imm_m[0] = 1'b0;

    assign {rs2, rs1, fun3} = inst[24:12];
    assign imm = {{19{imm_m[12]}}, imm_m};

    ysyx_25040111_MuxKeyWithDefault #(4, 3, `OPT_LEN) opt_c (opt, fun3, `OPT_LEN'b0, {
        3'b000, `OPTG(`XFS, `RF_RS, `EQUAL, `BRANCH, `EMPTY, `EXX),  // beq
        3'b001, `OPTG(`XFS, `RF_RS, `EQUAL, `BRANCH, `EMPTY, `EXN),  // bne
        3'b111, `OPTG(`XFS, `RF_RS, `COMPARE, `BRANCH, `EMPTY, `EXN),// bgeu
        3'b100, `OPTG(`XFS, `RF_RS, `COMPARE, `BRANCH, `EMPTY, `ESX) // blt
    });

endmodule
