`include "../ysyx_25040111_inc.vh"

module ysyx_25040111_load (
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rd,
    output [31:0] imm,
    output [`OPT_HIGH:0] opt
);

    wire [11:0] imm_m;
    wire [2:0] fun3;

    assign {imm_m, rs1, fun3, rd} = inst[31:7];
    assign imm = {{20{imm_m[11]}}, imm_m};

    ysyx_25040111_MuxKeyWithDefault #(5, 3, `OPT_LEN) opt_c (opt, fun3, `OPT_LEN'b0, {
        3'b010, `OPTG(`WFX, `RF_IM, `ADD, `SNPC, `MLW, `EMPTY),  // lw
        3'b100, `OPTG(`WFX, `RF_IM, `ADD, `SNPC, `MLB, `EMPTY),  // lbu
        3'b001, `OPTG(`WFX, `RF_IM, `ADD, `SNPC, `MLH, `XSX),    // lh
        3'b101, `OPTG(`WFX, `RF_IM, `ADD, `SNPC, `MLH, `EMPTY),  // lhu
        3'b000, `OPTG(`WFX, `RF_IM, `ADD, `SNPC, `MLB, `XSX)     // lb
    });

endmodule
