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

    ysyx_25040111_MuxKeyWithDefault #(1, 3, 32) imm_c (imm, fun3, 32'b0, {
        3'b000, {{20{imm_m[11]}}, imm_m[11:0]}
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 3, `OPT_LEN) opt_c (opt, fun3, `OPT_LEN'b0, {
        3'b000, `OPT_LEN'b0000000100111011  // rd = rs1 + imm
    });

endmodule
