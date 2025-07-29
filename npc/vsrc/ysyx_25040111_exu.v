`include "HDR/ysyx_25040111_inc.vh"
`include "HDR/ysyx_25040111_dpic.vh"
`include "ALU/ysyx_25040111_alu.v"

module ysyx_25040111_exu(
    input [`OPT_HIGH:0] opt,
    input [31:0] rs1_d,
    input [31:0] rs2_d,
    input [31:0] imm,
    input [31:0] pc,
    output [31:0] rd_d
);
    // -------------------------------------------------------
    //                        ALU
    // -------------------------------------------------------
    wire [31:0] var1;
    wire [31:0] var2;
    ysyx_25040111_MuxKey #(4, 2, 64) c_alu_arg({var1, var2}, opt[4:3], {
        2'b00, {imm, 32'b0},
        2'b01, {pc, imm},
        2'b10, {rs1_d, rs2_d},
        2'b11, {rs1_d, imm}
    });

    ysyx_25040111_alu u_ysyx_25040111_alu(
        .var1 	(var1  ),
        .var2 	(var2  ),
        .opt  	(opt[7:5]   ),
        .snpc   (opt[12:10] == 3'b100),
        .ext    (opt[13]),
        .sign   (opt[14]),
        .negate (opt[15]),
        .res  	(rd_d   )
    );
    
    // ------------------------------------------------------- 
    //                         SYSTEM
    // -------------------------------------------------------
    
    wire [31:0] eret;
    assign eret = opt[15] ? rs1_d : 32'd9;

`ifndef YOSYS_STA
    always @(*) begin
        if (opt == `EBREAK_INST)
            ebreak(eret);
    end
`endif // YOSYS_STA

endmodule
    // ysyx_25040111_RegisterFile #(8, 32) u_rom2_t(
    //     .clk   	(clk    ),
    //     .wen   	(|mem_en & ~opt[12]),
    //     .ren   	({1'b0, opt[12] & |mem_en}),
    //     .wdata 	(wdata),
    //     .waddr 	(res[7:0]),
    //     .raddr1 (res[7:0]),
    //     .rdata1 (rd_dt)
    // );
