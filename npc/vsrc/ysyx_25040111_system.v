`include "ysyx_25040111_inc.vh"

module ysyx_25040111_system(
    input [31:0] inst,
    output [4:0] rs1,
    output [`OPT_HIGH:0] opt 
);

    assign opt = inst == 32'h00100073 ? `EBREAK_INST : `INVALID_INST;
    assign rs1 = inst == 32'h00100073 ? 5'd10 : 5'd0;

endmodule
