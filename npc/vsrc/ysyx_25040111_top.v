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

    ysyx_25040111_ifu u_ifu (
        .clk    (clk    ),
        .ready  (1  ),
        .pc    	(pc     ),
        .inst  	(inst   ),
        .valid 	(  )
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
        .wen   	(opt[0]),
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
        .wen   	(opt[10] & opt[15]),
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
    ysyx_25040111_lsu u_ysyx_25040111_lsu(
        .wen   	(~opt[12] & mem_en),
        .ren   	(opt[12] & mem_en),
        .sign  	(opt[14]    ),
        .mask  	(opt[11:10] ),
        .shift 	(rd_dt[1:0] ),
        .addr  	(rd_dt      ),
        .wdata 	(rs2_d      ),
        .rdata 	(rdata      )
    );

    assign rs2_d = opt[15] & opt[11] ? csrd : rs2_dt;
    assign rd_d = opt[15] & opt[10] ? rs2_d : mem_en & opt[12] ? rdata : rd_dt;
    assign csrw = opt[15] & opt[10] ? rd_dt : 32'b0;
    
    ysyx_25040111_exu u_ysyx_25040111_exu(
        .valid  (1  ),
        .clk    (clk    ),
        .opt   	(opt    ),
        .rs1_d 	(rs1_d  ),
        .rs2_d 	(rs2_d  ),
        .imm   	(imm    ),
        .pc     (pc     ),
        .rd_d  	(rd_dt  )
    );

    // always @(posedge clk) begin
    //     $display("opt: %b", opt);
    //     $display("pc_next:%b  dnpc:%h  rd:%h", pc_next, dnpc, rd_d);
    // end
    
    ysyx_25040111_pcu u_ysyx_25040111_pcu(
        .clk       	(clk        ),
        .brench    	(rd_dt[0]   ),
        .opt       	(opt[9:8]   ),
        .mret      	(opt[15] & opt[12] ),
        .mret_addr 	(rs2_d  ),
        .imm       	(imm        ),
        .rs1_d     	(rs1_d      ),
        .pc        	(pc         )
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
