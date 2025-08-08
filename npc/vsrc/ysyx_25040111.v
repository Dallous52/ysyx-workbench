`include "HDR/ysyx_25040111_inc.vh"
`include "IDU/ysyx_25040111_idu.v"

module ysyx_25040111(
    input clock,
    input reset

`ifdef RUNSOC
    ,input          io_interrupt,

    input           io_master_awready,
    output          io_master_awvalid,
    output [31:0]   io_master_awaddr,
    output [3:0]    io_master_awid,
    output [7:0]    io_master_awlen,
    output [2:0]    io_master_awsize,
    output [1:0]    io_master_awburst,

    input           io_master_wready,
    output          io_master_wvalid,
    output [31:0]   io_master_wdata,
    output [3:0]    io_master_wstrb,
    output          io_master_wlast,

    output          io_master_bready,
    input           io_master_bvalid,
    input  [1:0]    io_master_bresp,
    input  [3:0]    io_master_bid,

    input           io_master_arready,
    output          io_master_arvalid,
    output [31:0]   io_master_araddr,
    output [3:0]    io_master_arid,
    output [7:0]    io_master_arlen,
    output [2:0]    io_master_arsize,
    output [1:0]    io_master_arburst,

    output          io_master_rready,
    input           io_master_rvalid,
    input  [1:0]    io_master_rresp,
    input  [31:0]   io_master_rdata,
    input           io_master_rlast,
    input  [3:0]    io_master_rid,

    output          io_slave_awready,
    input           io_slave_awvalid,
    input  [31:0]   io_slave_awaddr,
    input  [3:0]    io_slave_awid,
    input  [7:0]    io_slave_awlen,
    input  [2:0]    io_slave_awsize,
    input  [1:0]    io_slave_awburst,

    output          io_slave_wready,
    input           io_slave_wvalid,
    input  [31:0]   io_slave_wdata,
    input  [3:0]    io_slave_wstrb,
    input           io_slave_wlast,

    input           io_slave_bready,
    output          io_slave_bvalid,
    output [1:0]    io_slave_bresp,
    output [3:0]    io_slave_bid,

    output          io_slave_arready,
    input           io_slave_arvalid,
    input  [31:0]   io_slave_araddr,
    input  [3:0]    io_slave_arid,
    input  [7:0]    io_slave_arlen,
    input  [2:0]    io_slave_arsize,
    input  [1:0]    io_slave_arburst,

    input           io_slave_rready,
    output          io_slave_rvalid,
    output [1:0]    io_slave_rresp,
    output [31:0]   io_slave_rdata,
    output          io_slave_rlast,
    output [3:0]    io_slave_rid
`endif // RUNSOC
);

    // (icache : c) (ifu : f) (arbiter : a) (idu : d) (exu : x) 
    // (wbu : w)    (csr : s) (reg : r)     (lsu : l)

//-----------------------------------------------------------------
// CONTROL SIGNAL
//-----------------------------------------------------------------

    wire ifu_valid,     ifu_ready;
    wire icah_valid,    icah_ready;
    wire idu_valid,     idu_ready;
    wire exe_ready,     exe_valid;
    wire exu_rvalid,    exu_rready;
    wire exu_wvalid,    exu_wready;
    wire lsu_wready,    lsu_wvalid;
    wire lsu_rready,    lsu_rvalid;
    wire wbu_avalid,    wbu_aready; // from arbiter
    wire wbu_evalid,    wbu_eready; // from exu

    wire jpc_ready; // from exu

//-----------------------------------------------------------------
// DATA SIGNAL
//-----------------------------------------------------------------

    // exu <==> ifu
    wire [31:0]         ef_jpc;

    // idu <==> exu
    wire [31:0]         de_pc;
    wire [31:0]         de_imm;
    wire [`OPT_HIGH:0]  de_opt;
    wire [4:0]          de_ard;

    // idu <==> csr | reg
    wire [4:0]          dr_ars1,
                        dr_ars2;

    // csr | reg <==> exu
    wire [31:0]         re_rs1,
                        re_rs2;
    wire [31:0]         se_csr1,
                        se_csr2;

    // idu <==> ifu
    wire                df_jump;
    wire [31:0]         fd_inst;
    wire [31:0]         fd_pc;

    // ifu <==> icache
    wire [31:0]         fc_addr;
    wire [31:0]         cf_inst;

    // icache <==> arbiter
    wire                ca_burst;
    wire [7:0]          ca_rlen;
    wire [31:0]         ca_addr;
    wire [31:0]         ac_data;

    // arbiter <==> lsu
    wire [31:0]         al_waddr;
    wire [31:0]         al_raddr;
    wire [31:0]         al_wdata;
    wire [1:0]          al_wmask;
    wire [31:0]         la_rdata;
    wire [7:0]          al_rlen;
    wire [1:0]          al_rmask;
    wire                al_rsign;
    wire                al_burst;

    // exu <==> arbiter
    wire [31:0]         ea_waddr;
    wire [31:0]         ea_raddr;
    wire [31:0]         ea_wdata;
    wire [1:0]          ea_wmask, 
                        ea_rmask;
    wire                ea_rsign;
    wire [4:0]          ea_wbaddr;

    // arbiter <==> wbu
    wire [31:0]         aw_data;
    wire [4:0]          aw_addr;

//-----------------------------------------------------------------
// MODULE INSTANCES
//-----------------------------------------------------------------
    
    // IFU
    ysyx_25040111_ifu u_ifu(
        .clock     	(clock       ),
        .reset     	(reset       ),
        .ifu_addr  	(fc_addr     ),
        .ifu_inst  	(cf_inst     ),
        .jump      	(df_jump     ),
        .jump_pc  	(ef_jpc      ),
        .jpc_ready  (jpc_ready   ),
        .ifu_ready 	(ifu_ready   ),
        .ifu_valid 	(ifu_valid   ),
        .idu_inst   (fd_inst     ),
        .idu_pc     (fd_pc       ),
        .idu_valid 	(idu_valid   ),
        .idu_ready 	(idu_ready   )
    );

    // ICACHE
    ysyx_25040111_cache #(
        .CACHE_Ls 	(2  ),
        .BLOCK_Ls 	(3  ))
    u_icache(
        .clock  	(clock       ),
        .reset  	(reset       ),
        .addr   	(fc_addr     ),
        .data   	(cf_inst     ),
        .chburst    (ca_burst    ),
        .chaddr     (ca_addr     ),
        .chlen      (ca_rlen     ),
        .chdata  	(ac_data     ),
        .ifu_valid  (ifu_valid   ),
        .ifu_ready  (ifu_ready   ),
        .chvalid 	(icah_valid  ),
        .chready   	(icah_ready  )
    );

    // ARBITER
    ysyx_25040111_arbiter u_arbiter(
        .clock      (clock       ),
        .reset      (reset       ),
        .cah_valid  (icah_valid  ),
        .cah_ready  (icah_ready  ),
        .cah_addr   (ca_addr     ),
        .cah_data   (ac_data     ),
        .cah_burst  (ca_burst    ),
        .cah_rlen   (ca_rlen     ),
        .exu_rvalid (exu_rvalid  ),
        .exu_rready (exu_rready  ),
        .exu_raddr  (ea_raddr    ),
        .exu_rmask  (ea_rmask    ),
        .exu_rsign  (ea_rsign    ),
        .exu_wbaddr (ea_wbaddr   ),
        .wbu_valid  (wbu_avalid  ),
        .wbu_ready  (wbu_aready  ),
        .wbu_raddr  (aw_addr     ),
        .wbu_rdata  (aw_data     ),
        .exu_wvalid (exu_wvalid  ),
        .exu_wready (exu_wready  ),
        .exu_waddr  (ea_waddr    ),
        .exu_wdata  (ea_wdata    ),
        .exu_wmask  (ea_wmask    ),
        .lsu_rvalid (lsu_rvalid  ),
        .lsu_rready (lsu_rready  ),
        .lsu_rdata  (la_rdata    ),
        .lsu_raddr  (al_raddr    ),
        .lsu_rmask  (al_rmask    ),
        .lsu_rlen   (al_rlen     ),
        .lsu_burst  (al_burst    ),
        .lsu_wvalid (lsu_wvalid  ),
        .lsu_wready (lsu_wready  ),
        .lsu_wdata  (al_wdata    ),
        .lsu_wmask  (al_wmask    ),
        .lsu_waddr  (al_waddr    )
    );

    // IDU
    ysyx_25040111_idu u_idu(
        .clock     	(clock       ),
        .reset     	(reset       ),
        .idu_inst  	(fd_inst     ),
        .idu_ready 	(idu_ready   ),
        .idu_valid 	(idu_valid   ),
        .jump      	(df_jump     ),
        .exe_ready 	(exe_ready   ),
        .exe_valid 	(exe_valid   ),
        .rs1       	(rs1         ),
        .rs2       	(rs2         ),
        .rd        	(rd          ),
        .imm       	(imm         ),
        .opt       	(opt         ),
        .csr1      	(csr1        ),
        .csr2      	(csr2        ),
        .idu_pc     (fd_pc       ),
        .exe_pc     (de_pc       )
    );
    
    // LSU
    ysyx_25040111_lsu u_lsu(
        .clock      (clock       ),
        .reset      (reset       ),
        .lsu_rvalid (lsu_rvalid  ),
        .lsu_rready (lsu_rready  ),
        .lsu_rdata  (la_rdata    ),
        .lsu_raddr  (al_raddr    ),
        .lsu_rlen   (al_rlen     ),
        .lsu_burst  (al_burst    ),
        .lsu_rsign  (al_rsign    ),
        .lsu_rmask  (al_rmask    ),
        .lsu_wvalid (lsu_wvalid  ),
        .lsu_wready (lsu_wready  ),
        .lsu_wdata  (al_wdata    ),
        .lsu_waddr  (al_waddr    ),
        .lsu_wmask  (al_wmask    )
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
`endif
    );
    

endmodule
