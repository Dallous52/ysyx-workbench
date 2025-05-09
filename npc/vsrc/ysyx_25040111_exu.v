`include "ysyx_25040111_inc.vh"

import "DPI-C" function void ebreak(int code);

module ysyx_25040111_exu(
    input [`OPT_HIGH:3] opt,
    input [31:0] rs1_d,
    input [31:0] rs2_d,
    input [31:0] imm,
    input [31:0] pc,
    output [31:0] rd_d,
    output [31:0] dnpc
);

    ysyx_25040111_MuxKeyWithDefault #(5, 5, 32) temp_alu (rd_d, opt[7:3], 32'b0, {
        5'b00000, imm,
        5'b00101, pc + imm,
        5'b00110, rs1_d + rs2_d,
        5'b00111, rs1_d + imm,
        5'b11000, pc + 4
    });
    
    ysyx_25040111_MuxKey #(4, 2, 32) dnpc_new(dnpc, opt[9:8], {
        2'b00, pc + 4,
        2'b01, pc + imm,
        2'b10, rs1_d + imm,
        2'b11, pc
    });
    
    always @(*) begin
        $display("%b\n", opt);
        if (opt == 13'b0)
            ebreak(rs1_d);
    end

endmodule
