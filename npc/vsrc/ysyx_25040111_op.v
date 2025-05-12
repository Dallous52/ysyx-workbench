`include "ysyx_25040111_inc.vh"

`define OP_ADD  10'b0000000_000
`define OP_SUB  10'b0100000_000
`define OP_SLL  10'b0000000_001
`define OP_SLT  10'b0000000_010
`define OP_SLTU 10'b0000000_011
`define OP_XOR  10'b0000000_100
`define OP_SRL  10'b0000000_101
`define OP_SRA  10'b0100000_101
`define OP_OR   10'b0000000_110
`define OP_AND  10'b0000000_111

module ysyx_25040111_op(
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [`OPT_HIGH:0] opt
);

    wire [6:0] fun7;
    wire [2:0] fun3;

    assign {fun7, rs2, rs1, fun3, rd} = inst;

    ysyx_25040111_MuxKeyWithDefault #(2, 10, `OPT_LEN) opt_c (opt, {fun7, fun3}, `OPT_LEN'b0, {
        `OP_SUB, `OPTG(`WFS, `RF_RS, `ADD, `SNPC, `EMPTY, `SXX),
        `OP_ADD, `OPTG(`WFS, `RF_RS, `ADD, `SNPC, `EMPTY, `EMPTY)
    });

endmodule
