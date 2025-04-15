module ysyx_25040111_exu(
    input clk,
    input [4:0] opt,
    input [31:0] rs1_d,
    input [31:0] rs2_d,
    input [31:0] imm,
    output [31:0] rd_d
);

    wire [31:0] rs1_add_imm;
    
    assign rs1_add_imm = imm + rs1_d;

    ysyx_25040111_Reg #(32, 0) rd_r(
        .clk  	(clk   ),
        .rst  	(0   ),
        .din  	(rs1_add_imm),
        .dout 	(rd_d),
        .wen  	(opt == 5'b00001)
    );
    

endmodule
