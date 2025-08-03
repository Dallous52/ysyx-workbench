`include "../HDR/ysyx_25040111_inc.vh"

module ysyx_25040111_miscmem(
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rd,
    output [31:0] imm,
    output [`OPT_HIGH:0] opt
);

    wire [11:0] imm_m;
    wire [2:0] fun3;

    assign {imm_m, rs1, fun3, rd} = inst[31:7];

endmodule
