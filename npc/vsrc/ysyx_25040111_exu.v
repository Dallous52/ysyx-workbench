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
    reg [31:0] var1, var2;
    always @(*) begin
        case (opt[4:3])
            2'b00: begin
                var1 = imm; var2 = 32'b0;
            end
            2'b01: begin
                var1 = pc; var2 = imm;
            end
            2'b10: begin
                var1 = rs1_d; var2 = rs2_d;
            end
            2'b11: begin
                var1 = rs1_d; var2 = imm;
            end
        endcase
    end

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
