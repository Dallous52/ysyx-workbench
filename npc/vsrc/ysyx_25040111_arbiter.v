module ysyx_25040111_arbiter(
    input           clock,
    input           reset,

    input           cah_valid,
    input  [31:0]   cah_addr,
    output          cah_ready,
    output [31:0]   cah_data,
    input           cah_burst,
    input  [7:0]    cah_rlen,

    input           exu_rvalid,
    input  [31:0]   exu_raddr,
    input  [4:0]    exu_wbaddr,
    output          exu_rready,
    input  [1:0]    exu_rmask,
    input           exu_rsign,
    output [31:0]   wbu_rdata,
    output [4:0]    wbu_raddr,
    output          wbu_valid,
    input           wbu_ready,

    input           exu_wvalid,
    input  [31:0]   exu_waddr,
    output          exu_wready,
    input  [31:0]   exu_wdata,
    input  [1:0]    exu_wmask,

    output          lsu_rvalid,
    input           lsu_rready,
    input  [31:0]   lsu_rdata,
    output [31:0]   lsu_raddr,
    output [7:0]    lsu_rlen,
    output          lsu_burst,
    output          lsu_rsign,
    output [1:0]    lsu_rmask,

    output          lsu_wvalid,
    input           lsu_wready,
    output [31:0]   lsu_wdata,
    output [31:0]   lsu_waddr,
    output [1:0]    lsu_wmask
);

//-----------------------------------------------------------------
// External Interface
//-----------------------------------------------------------------

    // exu write
    assign lsu_wvalid   = wvalid;
    assign exu_wready   = wready;
    assign lsu_waddr    = waddr;
    assign lsu_wdata    = wdata;
    assign lsu_wmask    = wmask;

    // exu ready
    assign exu_rready   = rready;
    assign wbu_rdata    = rdata;
    assign wbu_raddr    = wbaddr;
    assign wbu_valid    = wbvalid;

    // lsu ready
    assign lsu_raddr    = ~rvalid & cah_valid ? cah_addr  : raddr;
    assign lsu_rvalid   = ~rvalid & cah_valid ? cah_valid : rvalid;
    assign lsu_rlen     = ~rvalid & cah_valid ? cah_rlen  : 8'b0;
    assign lsu_burst    = ~rvalid & cah_valid ? cah_burst : 1'b0;
    assign lsu_rmask    = ~rvalid & cah_valid ? 2'b11     : rmask;
    assign lsu_rsign    = ~rvalid & cah_valid ? 1'b0      : rsign;

    // cache inst fetch
    assign cah_ready = ~rvalid & cah_valid ? lsu_rready   : 1'b0;
    assign cah_data  = ~rvalid & cah_valid ? lsu_rdata    : 0;

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------

    reg         wvalid;
    reg         wready;
    reg [31:0]  waddr;
    reg [31:0]  wdata;
    reg [1:0]   wmask;

    reg         rvalid;
    reg         rready;
    reg [31:0]  raddr;
    reg [31:0]  rdata;
    reg [1:0]   rmask;
    reg         rsign;
    reg [4:0]   wbaddr;
    reg         wbvalid;

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    // wvalid waddr wdata
    always @(posedge clock) begin
        if (reset) begin
            wvalid <= 1'b0;
            waddr  <= 0;
            wdata  <= 0;            
            wmask  <= 2'b0;
        end
        else if (exu_wvalid & ~wvalid) begin
            wvalid <= 1'b1;
            waddr  <= exu_waddr;
            wdata  <= exu_wdata;
            wmask  <= exu_wmask;
        end
        else if (lsu_wready & wvalid)
            wvalid <= 1'b0;
    end

    // wready
    always @(posedge clock) begin
        if (reset)
            wready <= 1'b0;
        else if (exu_wvalid & ~wvalid)
            wready <= 1'b1;
        else 
            wready <= 1'b0;
    end

    // rvalid raddr rdata
    always @(posedge clock) begin
        if (reset) begin
            rvalid <= 1'b0;
            raddr  <= 0;
            rdata  <= 0;
            rsign  <= 1'b0;
            rmask  <= 2'b0;
        end
        else if (exu_rvalid & ~rvalid & ~cah_valid) begin
            rvalid <= 1'b1;
            raddr  <= exu_raddr;
            rmask  <= exu_rmask;
            rsign  <= exu_rsign; 
        end
        else if (lsu_rready & rvalid) begin
            rdata <= lsu_rdata;
        end
        else if (wbu_ready & wbu_valid)
            rvalid <= 1'b0;
    end

    // rready
    always @(posedge clock) begin
        if (reset)
            rready <= 1'b0;
        else if (exu_rvalid & ~rvalid)
            rready <= 1'b1;
        else 
            rready <= 1'b0;
    end

    // wbaddr wbvalid
    always @(posedge clock) begin
        if (reset) begin
            wbaddr <= 5'b0;
            wbvalid <= 1'b0;
        end
        else if (exu_rvalid & ~rvalid)
            wbaddr <= exu_wbaddr;
        else if (lsu_rready & rvalid)
            wbvalid <= 1'b1;
        else if (wbu_valid & wbu_ready)
            wbvalid <= 1'b0; 
    end

endmodule
