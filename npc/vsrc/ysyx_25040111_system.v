
module ysyx_25040111_system(
    input [31:0] inst,
    output [4:0] rs1,
    output [9:0] opt 
);

    assign opt = inst == 32'h00100073 ? 10'b1111111010 : 10'b0;
    assign rs1 = inst == 32'h00100073 ? 5'd10 : 5'b0;

endmodule
