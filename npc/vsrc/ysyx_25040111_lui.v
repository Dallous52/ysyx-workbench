module ysyx_25040111_lui(
      input [31:7] inst,
    output [4:0] rd,
    output [31:0] imm,
    output [7:0] opt
);

    wire [31:12] imm_m;

    assign {imm_m, rd} = inst[31:7];

    assign imm = {imm_m, 12'b0};

    assign opt = 8'b00000001;
    
endmodule
