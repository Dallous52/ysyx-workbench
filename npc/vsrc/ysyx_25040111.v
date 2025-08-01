`include "HDR/ysyx_25040111_inc.vh"
`include "IDU/ysyx_25040111_idu.v"

module ysyx_25040111(
    input clock,
    input reset,

    output [31:0] pc,
    output [31:0] inst
`ifdef RUNSOC
    ,input io_interrupt,

    input io_master_awready,
    output io_master_awvalid,
    output [31:0] io_master_awaddr,
    output [3:0] io_master_awid,
    output [7:0] io_master_awlen,
    output [2:0] io_master_awsize,
    output [1:0] io_master_awburst,

    input io_master_wready,
    output io_master_wvalid,
    output [31:0] io_master_wdata,
    output [3:0] io_master_wstrb,
    output io_master_wlast,

    output io_master_bready,
    input io_master_bvalid,
    input [1:0] io_master_bresp,
    input [3:0] io_master_bid,

    input io_master_arready,
    output io_master_arvalid,
    output [31:0] io_master_araddr,
    output [3:0] io_master_arid,
    output [7:0] io_master_arlen,
    output [2:0] io_master_arsize,
    output [1:0] io_master_arburst,

    output io_master_rready,
    input io_master_rvalid,
    input [1:0] io_master_rresp,
    input [31:0] io_master_rdata,
    input io_master_rlast,
    input [3:0] io_master_rid,

    output io_slave_awready,
    input io_slave_awvalid,
    input [31:0] io_slave_awaddr,
    input [3:0] io_slave_awid,
    input [7:0] io_slave_awlen,
    input [2:0] io_slave_awsize,
    input [1:0] io_slave_awburst,

    output io_slave_wready,
    input io_slave_wvalid,
    input [31:0] io_slave_wdata,
    input [3:0] io_slave_wstrb,
    input io_slave_wlast,

    input io_slave_bready,
    output io_slave_bvalid,
    output [1:0] io_slave_bresp,
    output [3:0] io_slave_bid,

    output io_slave_arready,
    input io_slave_arvalid,
    input [31:0] io_slave_araddr,
    input [3:0] io_slave_arid,
    input [7:0] io_slave_arlen,
    input [2:0] io_slave_arsize,
    input [1:0] io_slave_arburst,

    input io_slave_rready,
    output io_slave_rvalid,
    output [1:0] io_slave_rresp,
    output [31:0] io_slave_rdata,
    output io_slave_rlast,
    output [3:0] io_slave_rid
`endif // RUNSOC
);

// ------------------------------------------------
//                I/O SIGNAL DEFINE
// ------------------------------------------------

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [11:0] csr [1:0];
    wire [31:0] imm;
    wire [`OPT_HIGH:0] opt;

    wire inst_ok, args_ok, next_ok;

    wire if_flag;
    ysyx_25040111_ifu u_ifu (
        .clk    (clock          ),
        .reset  (reset          ),
        .ready  (next_ok        ),
        .if_flag(if_flag        ),
        .start  (icache_valid   ),
        .inst_t (icache_data    ),
        .inst   (inst           ),
        .if_ok  (icache_ready   ),
        .valid  (inst_ok        )
    );

    wire [31:0] icache_data;
    wire [31:0] icache_addr;
    wire [7:0]  tlen;
    wire icache_ready;
    wire icache_valid;
    wire icache_rok = if_flag ? lsu_ok : 1'b0; 
    wire if_start;
    `ifdef RUNSOC        
    wire icache_burst = pc[31:28] == 4'ha;
    `else
    wire icache_burst = 1'b0;
    `endif

    ysyx_25040111_cache #(
        .CACHE_Ls 	(3  ),
        .BLOCK_Ls 	(3  ))
    u_icache(
        .clock  	(clock          ),
        .reset  	(reset          ),
        .addr   	(pc             ),
        .rburst     (icache_burst   ),
        .raddr      (icache_addr    ),
        .data   	(icache_data    ),
        .rstart 	(if_start       ),
        .rlen       (tlen           ),
        .rok    	(icache_rok     ),
        .rdata  	(lsu_rdata      ),
        .valid  	(icache_valid   ),
        .ready  	(icache_ready   )
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
        .clk   	(clock     ),
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
        .clk   	(clock     ),
        .reset  (reset),
        .wen   	(opt[10] & opt[15] & args_ok),
        .ren   	(opt[11] & opt[15]),
        .waddr 	(csr[0]  ),
        .jtype    (opt[9:8]),
        .wdata 	(csrw    ),
        .raddr 	(csr[1]  ),
        .rdata 	(csrd    )
    );

    wire [31:0] rdata;
    wire mem_en = |opt[11:10] & ~opt[15];

    // simple arbiter
    wire lsu_ready = if_flag ? if_start : inst_ok;
    wire lsu_wen = if_flag ? 0 : ~opt[12] & mem_en;
    wire lsu_ren = if_flag ? 1 : opt[12] & mem_en;
    wire [1:0] lsu_mask = if_flag ? 2'b11 : opt[11:10];
    wire [7:0] lsu_tlen = if_flag ? tlen : 8'b0;
    wire [31:0] lsu_addr = if_flag ? icache_addr : rd_dt;
    wire [31:0] lsu_rdata;
    wire lsu_ok;

    ysyx_25040111_lsu u_lsu(
        .clk    (clock),
        .ready  (lsu_ready),
        .wen   	(lsu_wen),
        .ren   	(lsu_ren),
        .sign  	(opt[14]    ),
        .mask  	(lsu_mask),
        .addr  	(lsu_addr      ),
        .wdata 	(rs2_d      ),
        .rdata 	(lsu_rdata      ),
        .tlen   (lsu_tlen),
        .valid  (lsu_ok)
`ifdef RUNSOC
        ,.io_master_awready (io_master_awready  ),
        .io_master_awvalid 	(io_master_awvalid  ),
        .io_master_awaddr  	(io_master_awaddr   ),
        .io_master_awid    	(io_master_awid     ),
        .io_master_awlen   	(io_master_awlen    ),
        .io_master_awsize  	(io_master_awsize   ),
        .io_master_awburst 	(io_master_awburst  ),
        .io_master_wready  	(io_master_wready   ),
        .io_master_wvalid  	(io_master_wvalid   ),
        .io_master_wdata   	(io_master_wdata    ),
        .io_master_wstrb   	(io_master_wstrb    ),
        .io_master_wlast   	(io_master_wlast    ),
        .io_master_bready  	(io_master_bready   ),
        .io_master_bvalid  	(io_master_bvalid   ),
        .io_master_bresp   	(io_master_bresp    ),
        .io_master_bid     	(io_master_bid      ),
        .io_master_arready 	(io_master_arready  ),
        .io_master_arvalid 	(io_master_arvalid  ),
        .io_master_araddr  	(io_master_araddr   ),
        .io_master_arid    	(io_master_arid     ),
        .io_master_arlen   	(io_master_arlen    ),
        .io_master_arsize  	(io_master_arsize   ),
        .io_master_arburst 	(io_master_arburst  ),
        .io_master_rready  	(io_master_rready   ),
        .io_master_rvalid  	(io_master_rvalid   ),
        .io_master_rresp   	(io_master_rresp    ),
        .io_master_rdata   	(io_master_rdata    ),
        .io_master_rlast   	(io_master_rlast    ),
        .io_master_rid     	(io_master_rid      )
`endif // RUNSOC
    );

    assign rdata = if_flag ? 32'b0 : lsu_rdata;
    assign args_ok = if_flag ? 0 : lsu_ok;

    assign rs2_d = opt[15] & opt[11] ? csrd : rs2_dt;
    assign rd_d = opt[15] & opt[10] ? rs2_d :
           mem_en & opt[12] ? rdata : rd_dt;
    assign csrw = opt[15] & opt[10] ? rd_dt : 32'b0;

    ysyx_25040111_exu u_exu(
        .opt   	(opt    ),
        .rs1_d 	(rs1_d  ),
        .rs2_d 	(rs2_d  ),
        .imm   	(imm    ),
        .pc     (pc     ),
        .rd_d  	(rd_dt  )
    );

    ysyx_25040111_pcu u_pcu(
        .clk          (clock        ),
        .reset        (reset),
        .ready        (args_ok    ),
        .brench    	(rd_dt[0]   ),
        .opt       	(opt[9:8]   ),
        .mret      	(opt[15] & opt[12]),
        .mret_addr 	(rs2_d      ),
        .imm       	(imm        ),
        .rs1_d     	(rs1_d      ),
        .pc        	(pc         ),
        .valid        (next_ok)
    );

endmodule
