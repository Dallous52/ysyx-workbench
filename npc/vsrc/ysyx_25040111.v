`include "HDR/ysyx_25040111_inc.vh"
`include "IDU/ysyx_25040111_idu.v"

module ysyx_25040111(
    input clock,
    input reset

`ifdef RUNSOC
    ,input io_interrupt,

    input  io_master_awready,
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

//-----------------------------------------------------------------
// CONTROL SIGNAL
//-----------------------------------------------------------------

    wire ifu_valid,     ifu_ready;
    wire icache_valid,  icache_ready;
    wire idu_valid,     idu_ready;
    
    wire jpc_ready; // from wbu

//-----------------------------------------------------------------
// DATA SIGNAL
//-----------------------------------------------------------------

    // (icache : c) (ifu : f) (arbiter : a) (idu : d) (exu : x) 
    // (wbu : b)    (csr : s) (reg : r)     (lsu : l)

    // wbu <==> ifu
    wire [31:0] bf_jpc;

    // idu <==> ifu
    wire        df_jump;
    wire [31:0] fd_inst;

    // ifu <==> icache
    wire [31:0] fc_addr;
    wire [31:0] cf_inst;

    // icache <==> arbiter
    wire        ca_burst;
    wire [7:0]  ca_burst_len;
    wire [31:0] ca_addr;
    wire [31:0] ac_data;

//-----------------------------------------------------------------
// MODULE INSTANCES
//-----------------------------------------------------------------
    
    // IFU
    ysyx_25040111_ifu u_ifu(
        .clock     	(clock      ),
        .reset     	(reset      ),
        .ifu_addr  	(fc_addr    ),
        .ifu_inst  	(cf_inst    ),
        .jump      	(df_jump    ),
        .idu_inst   (fd_inst    ),
        .jump_pc  	(bf_jpc     ),
        .jpc_ready  (jpc_ready  ),
        .ifu_ready 	(ifu_ready  ),
        .ifu_valid 	(ifu_valid  ),
        .idu_valid 	(idu_valid  ),
        .idu_ready 	(idu_ready  )
    );

    // ICACHE
    ysyx_25040111_cache #(
        .CACHE_Ls 	(2  ),
        .BLOCK_Ls 	(3  ))
    u_icache(
        .clock  	(clock          ),
        .reset  	(reset          ),
        .addr   	(fc_addr        ),
        .data   	(cf_inst        ),
        .chburst    (ca_burst       ),
        .chaddr     (ca_addr        ),
        .chlen      (ca_burst_len   ),
        .chdata  	(ac_data        ),
        .ifu_valid  (ifu_valid      ),
        .ifu_ready  (ifu_ready      ),
        .chvalid 	(icache_valid   ),
        .chready   	(icache_ready   )
    );

    // IDU

endmodule
