// OPT [15:0]
//      [0]: reg wirte en (write to rd)
//      [2:1]: reg read en [rs2, rs1]
//      [4:3]: alu arguments
//              00  empty
//              01  pc, imm (alu-eopt == 100 ? imm = 4 : imm)
//              10  rs1, rs2
//              11  rs1, imm
//      [7:5]: alu option
//              000 empty
//              001 add [13] sub
//              010 and [13] or
//              011 xor
//              100 lshift
//              101 rshift
//              110 compare
//              111 equal
//      [9:8]: pc update option             SYSTEM JUMP TYPE 
//              00 empty                        00 empty
//              01 pc + 4                       01 ecall
//              10 pc + imm                     10 ??
//              11 rs1 + imm                    11 ??
//      [12:10] memory control option       SYSTEM
//              000 empty                       [10] csr write en
//              001 sb                          [11] csr read en
//              010 sh                          [12] jump
//              011 sw
//              101 lb
//              110 lh
//              111 lw
//              100 pc + 4 [alu-eopt]
//      [13]    [add:sub] | [and:or]
//      [14]    signed enable
//      [15]    [system opt] | [cmp-eq !res]

`include "ysyx_25040111_inc.vh" 

module ysyx_25040111_top(
    input clk,
    input rst,
    output [31:0] pc
);
   
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [11:0] csr [1:0];
    wire [31:0] imm;
    wire [`OPT_HIGH:0] opt;
    wire [31:0] inst;
    
    wire valid;
    
    ysyx_25040111_ifu u_ifu (
        .clk    (clk    ),
        .ready  (~valid ),
        .pc    	(pc     ),
        .inst  	(inst   ),
        .valid 	(valid  )
    );

    ysyx_25040111_idu u_idu (
        .inst 	(valid ? inst : 32'b0),
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
        .clk   	(clk    ),
        .wen   	(opt[0] ),
        .ren   	(opt[2:1]),
        .wdata 	(rd_d   ),
        .waddr 	(rd[3:0] ),
        .raddr1 (rs1[3:0]),
        .raddr2 (rs2[3:0]),
        .rdata1 (rs1_d),
        .rdata2 (rs2_dt)
    );
    
    wire [31:0] csrw_t;
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

    assign rs2_d = opt[15] & opt[11] ? csrd : rs2_dt;
    assign rd_d = opt[15] & opt[10] ? csrw_t : rd_dt;
    assign csrw = opt[15] & opt[10] ? rd_dt : 32'b0;
    
    wire [31:0] dnpc;
    ysyx_25040111_exu u_ysyx_25040111_exu(
        .opt   	(opt    ),
        .rs1_d 	(rs1_d  ),
        .rs2_d 	(rs2_d  ),
        .imm   	(imm    ),
        .pc     (pc     ),
        .clk    (clk    ),
        .rd_d  	(rd_dt  ),
        .dnpc   (dnpc   ),
        .csrw   (csrw_t )
    );

    ysyx_25040111_Reg #(32, 32'h80000000) u_ysyx_25040111_Reg(
        .clk  	(clk   ),
        .rst  	(rst   ),
        .din  	(dnpc  ),
        .dout 	(pc    ),
        .wen  	(1     )
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
