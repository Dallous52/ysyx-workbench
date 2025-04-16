module ysyx_25040111_exu(
    input [4:0] opt,
    input [31:0] rs1_d,
    input [31:0] rs2_d,
    input [31:0] imm,
    output [31:0] rd_d
);

    ysyx_25040111_MuxKeyWithDefault #(1, 5, 32) rs1_add_imm (rd_d, opt, 32'b0, {
        5'b00001, imm + rs1_d
    });
    

endmodule
