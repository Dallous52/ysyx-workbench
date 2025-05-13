`include "ysyx_25040111_inc.vh"

module ysyx_25040111_opimm (
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rd,
    output [31:0] imm,
    output [`OPT_HIGH:0] opt
);

    wire [11:0] imm_m;
    wire [2:0] fun3;

    assign {imm_m, rs1, fun3, rd} = inst[31:7];

    ysyx_25040111_MuxKeyWithDefault #(2, 3, 32) imm_c (imm, fun3, {{20{imm_m[11]}}, imm_m}, {
        3'b001, {27'b0, imm_m[4:0]},
        3'b101, {27'b0, imm_m[4:0]}
    });

    ysyx_25040111_MuxKeyWithDefault #(4, 3, `OPT_LEN) opt_c (opt, fun3, `OPT_LEN'b0, {
        3'b000, `OPTG(`WFX, `RF_IM, `ADD, `SNPC, `EMPTY, `EMPTY),       // addi
        3'b011, `OPTG(`WFX, `RF_IM, `COMPARE, `SNPC, `EMPTY, `EXX),     // sltiu
        3'b101, `OPTG(`WFX, `RF_IM, `RSHIFT, `SNPC, `EMPTY, {1'b0, inst[30], 1'b0}), // srai srli
        3'b111, `OPTG(`WFX, `RF_IM, `AND, `SNPC, `EMPTY, `EMPTY)
    });

endmodule
