module ysyx_25040111_opimm_addi(
    input en,
    input [11:0] imm,
    input [4:0] rd,
    output [31:0] wdata,
    output [4:0] waddr
);

    assign wdata = en ? {{20{imm[11]}}, imm} : 32'd0;
    assign waddr = en ? rd : 5'd0;

endmodule
