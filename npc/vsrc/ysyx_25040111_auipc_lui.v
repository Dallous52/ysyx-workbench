module ysyx_25040111_auipc_lui(
    input [31:7] inst,
    input chos,
    output [4:0] rd,
    output [31:0] imm,
    output [9:0] opt
);

    wire [31:12] imm_m;

    assign {imm_m, rd} = inst[31:7];

    assign imm = {imm_m, 12'b0};

    assign opt = chos ? 10'b0000000001 : 10'b0000100001;

endmodule
