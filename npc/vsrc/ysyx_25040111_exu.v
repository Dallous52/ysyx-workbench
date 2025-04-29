module ysyx_25040111_exu(
    input [7:3] opt,
    input [31:0] rs1_d,
    input [31:0] rs2_d,
    input [31:0] imm,
    input [31:0] pc,
    output [31:0] rd_d
);

    ysyx_25040111_MuxKeyWithDefault #(4, 5, 32) rs1_add_imm (rd_d, opt[7:3], 32'b0, {
        5'b00000, imm,
        5'b00100, pc + imm,
        5'b00101, rs1_d + rs2_d,
        5'b00110, rs1_d + imm
    });
    

endmodule
