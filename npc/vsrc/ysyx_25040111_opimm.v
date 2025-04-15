module ysyx_25040111_opimm (
    input en,
    input clk,
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rd,
    output [31:0] imm,
    output [4:0] opt
);

    wire [31:0] imm_t;
    wire [11:0] imm_m;
    wire [2:0] fun3;
    wire [4:0] rd_t, rs1_t, opt_t;

    assign {imm_m, rs1_t, fun3, rd_t} = inst[31:7];

    ysyx_25040111_MuxKeyWithDefault #(1, 3, 32) imm_c (imm_t, fun3, 32'b0, {
        3'b000, {{20{imm_m[11]}}, imm_m[11:0]}
    });

    ysyx_25040111_MuxKeyWithDefault #(1, 3, 5) opt_c (opt_t, fun3, 5'b0, {
        3'b000, 5'b00001  // rd = rs1 + imm
    });


    ysyx_25040111_Reg #(5, 0) rs1_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(rs1_t  ),
        .dout 	(rs1  ),
        .wen  	(en   )
    );

    ysyx_25040111_Reg #(5, 0) rd_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(rd_t),
        .dout 	(rd  ),
        .wen  	(en   )
    );
    
    ysyx_25040111_Reg #(32, 0) imm_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(imm_t),
        .dout 	(imm  ),
        .wen  	(en   )
    );

    ysyx_25040111_Reg #(5, 0) opt_r (
        .clk  	(clk ),
        .rst  	(0   ),
        .din  	(opt_t),
        .dout 	(opt  ),
        .wen  	(en   )
    );

endmodule
