`include "HDR/ysyx_25040111_inc.vh" 
`include "IDU/ysyx_25040111_idu.v"

module ysyx_25040111_top(
    input clk,
    output reg [31:0] pc
);
   
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [11:0] csr [1:0];
    wire [31:0] imm;
    wire [`OPT_HIGH:0] opt;
    wire [31:0] inst;

    reg inst_ok, args_ok, next_ok;
    initial begin
        next_ok = 1;
        inst_ok = 0;
        args_ok = 0;
    end

    wire if_flag;
    ysyx_25040111_ifu u_ifu (
        .clk    (clk    ),
        .ready  (next_ok),
        .if_flag (if_flag),
        .inst_t (lsu_rdata),
        .inst  	(inst   ),
        .if_ok  (lsu_ok),
        .valid 	(inst_ok)
    );

    ysyx_25040111_idu u_idu (
        .inst 	(inst  ),
        .rs1  	(rs1   ),
        .rs2  	(rs2   ),
        .rd   	(rd    ),
        .imm  	(imm   ),
        .opt  	(opt   ),
        .csr1   (csr[0]),
        .csr2   (csr[1])
    );

    wire [31:0] rs2_dt, rd_dt;
    wire [31:0] rs1_d, rs2_d, rd_d;

    ysyx_25040111_RegisterFile #(4, 32) u_reg(
        .clk   	(clk     ),
        .wen   	(opt[0] & args_ok),
        .ren   	(opt[2:1]),
        .wdata 	(rd_d    ),
        .waddr 	(rd[3:0] ),
        .raddr1 (rs1[3:0]),
        .raddr2 (rs2[3:0]),
        .rdata1 (rs1_d   ),
        .rdata2 (rs2_dt  )
    );
    
    wire [31:0] csrw, csrd;
    ysyx_25040111_csr u_csr(
        .clk   	(clk     ),
        .wen   	(opt[10] & opt[15] & args_ok),
        .ren   	(opt[11] & opt[15]),
        .waddr 	(csr[0]  ),
        .jtype  (opt[9:8]),
        .wdata 	(csrw    ),
        .raddr 	(csr[1]  ),
        .rdata 	(csrd    )
    );

    wire [31:0] rdata;
    wire mem_en;
    assign mem_en = |opt[11:10] & ~opt[15];
    
    // simple arbiter
    wire lsu_ready;
    assign isu_ready = if_flag ? next_ok : inst_ok;
    wire lsu_wen;
    assign isu_wen = if_flag ? 0 : ~opt[12] & mem_en;
    wire lsu_ren;
    assign lsu_ren = if_flag ? 1 : opt[12] & mem_en;
    wire [1:0] lsu_mask;
    assign lsu_mask = if_flag ? 2'b11 : opt[11:10];
    wire [31:0] lsu_addr;
    assign lsu_addr = if_flag ? pc : rd_dt;
    wire [31:0] lsu_rdata;
    wire lsu_ok;

    ysyx_25040111_lsu u_ysyx_25040111_lsu(
        .clk    (clk),
        .ready  (lsu_ready),
        .wen   	(isu_wen),
        .ren   	(lsu_ren),
        .sign  	(opt[14]    ),
        .mask  	(lsu_mask),
        .addr  	(lsu_addr      ),
        .wdata 	(rs2_d      ),
        .rdata 	(lsu_rdata      ),
        .valid  (lsu_ok)
    );

    assign rdata = if_flag ? 32'b0 : lsu_rdata;
    assign args_ok = if_flag ? 0 : lsu_ok;

    assign rs2_d = opt[15] & opt[11] ? csrd : rs2_dt;
    assign rd_d = opt[15] & opt[10] ? rs2_d : 
        mem_en & opt[12] ? rdata : rd_dt;
    assign csrw = opt[15] & opt[10] ? rd_dt : 32'b0;
    
    ysyx_25040111_exu u_ysyx_25040111_exu(
        .opt   	(opt    ),
        .rs1_d 	(rs1_d  ),
        .rs2_d 	(rs2_d  ),
        .imm   	(imm    ),
        .pc     (pc     ),
        .rd_d  	(rd_dt  )
    );

    // always @(posedge clk) begin
    //     $display("opt: %b", opt);
    //     $display("inst:%b  args:%b  next:%b", inst_ok, args_ok, next_ok);
    // end
    
    ysyx_25040111_pcu u_ysyx_25040111_pcu(
        .clk       	(clk        ),
        .ready      (args_ok    ),
        .brench    	(rd_dt[0]   ),
        .opt       	(opt[9:8]   ),
        .mret      	(opt[15] & opt[12]),
        .mret_addr 	(rs2_d      ),
        .imm       	(imm        ),
        .rs1_d     	(rs1_d      ),
        .pc        	(pc         ),
        .valid      (next_ok)
    );
    
endmodule

    // ysyx_25040111_RegisterFile #(8, 32) u_rom_t(
    //     .clk   	(clk    ),
    //     .wen   	(0    ),
    //     .ren   	(2'b01    ),
    //     .wdata 	(  ),
    //     .waddr 	(  ),
    //     .raddr1 (pc[8:0]),
    //     .raddr2 (),
    //     .rdata1 ( inst),
    //     .rdata2 ()
    // );
