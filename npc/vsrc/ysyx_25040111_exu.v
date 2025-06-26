`include "ysyx_25040111_inc.vh"
`include "ysyx_20540111_dpic.vh"

module ysyx_25040111_exu(
    input valid,
    input clk,
    input [`OPT_HIGH:0] opt,
    input [31:0] rs1_d,
    input [31:0] rs2_d,
    input [31:0] imm,
    input [31:0] pc,
    output [31:0] rd_d,
    output [31:0] dnpc,
    output [31:0] csrw,
    output reg ready
);
    // ------------------------------------------------------- 
    //                        ALU
    // -------------------------------------------------------
    wire [31:0] res;
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
        .res  	(res   )
    );
    
    // ------------------------------------------------------- 
    //                        PC UPDATE
    // -------------------------------------------------------
    wire [31:0] ina;
    wire [31:0] inb;
    wire [1:0] pc_ctl, pc_tmp;
    
    assign pc_tmp = |opt[9:8] ? opt[9:8] : res[0] ? `INPC : `SNPC;
    assign pc_ctl = valid ? pc_tmp : 2'b0; 
    ysyx_25040111_MuxKey #(4, 2, 64) c_pc_arg({ina, inb}, pc_ctl, {
        2'b00, {pc, 32'b0},
        2'b01, {pc, 32'd4},
        2'b10, {pc, imm},
        2'b11, {rs1_d, imm}
    });

    wire [31:0] dnpc_normal;
    ysyx_25040111_adder32 u_ysyx_25040111_adder32(
        .ina  	    (ina   ),
        .inb  	    (inb   ),
        .sub        (0),
        .sout 	    (dnpc_normal),
        .cout       (),
        .overflow   ()
    );

    // mret
    assign dnpc = opt[15] & opt[12] ? rs2_d : dnpc_normal;
    
    // ------------------------------------------------------- 
    //                        MEMORY
    // -------------------------------------------------------
    wire [1:0] mem_en, shif_en;
    assign mem_en = opt[15] ? 2'b00 : opt[11:10];
    assign shif_en = opt[15] ? 2'b00 : res[1:0];

    wire [7:0] wmask;    
    ysyx_25040111_MuxKey #(4, 2, 8) c_wmask(wmask, mem_en, {
        2'b00, 8'h00,
        2'b01, 8'b00000001 << res[1:0],
        2'b10, res[1] ? 8'b00001100 : 8'b00000011,
        2'b11, 8'b00001111
    });

    wire [31:0] wdata;
    ysyx_25040111_MuxKey #(4, 2, 32) c_wt_data(wdata, shif_en, {
        2'b00, rs2_d,
        2'b01, rs2_d << 8,
        2'b10, rs2_d << 16,
        2'b11, rs2_d << 24
    }); 
    
    reg [31:0] rd_dt;
    always @(posedge clk) begin
        if (|mem_en) begin
            if (~opt[12]) begin // 有写请求时
                pmem_write(res, wdata, wmask);
                rd_dt <= 0;
            end
            else begin          // 有读请求时\
                rd_dt <= pmem_read(res);
                ready <= 1;
            end
        end
        else rd_dt <= 0;
        $display("res:%h rd_dt:%h", res, rd_dt);

        if (ready) ready <= 0;
    end

    wire [31:0] offset;
    ysyx_25040111_MuxKey #(4, 2, 32) c_rd_data(offset, shif_en, {
        2'b00, rd_dt,
        2'b01, rd_dt >> 8,
        2'b10, rd_dt >> 16,
        2'b11, rd_dt >> 24
    });

    ysyx_25040111_MuxKey #(4, 2, 32) c_rdmem(rd_d, mem_en, {
        2'b00, res,
        2'b01, {{24{offset[7] & opt[14]}}, offset[7:0]},
        2'b10, {{16{offset[15] & opt[14]}}, offset[15:0]},
        2'b11, offset
    });

    
    // ------------------------------------------------------- 
    //                         SYSTEM
    // -------------------------------------------------------
    
    assign csrw = rs2_d;

    wire [31:0] eret;
    assign eret = opt[15] ? rs1_d : 32'd9;
    always @(*) begin
        if (opt == `EBREAK_INST)
            ebreak(eret);
    end


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
