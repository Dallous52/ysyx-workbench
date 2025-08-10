module ysyx_25040111_arbiter(
    input           clock,
    input           reset,

    input           cah_valid,
    input  [31:0]   cah_addr,
    output          cah_ready,
    output [31:0]   cah_data,
    input           cah_burst,
    input  [7:0]    cah_rlen,

    input           exu_valid,
    output          exu_ready,
    input           exu_men,

    input  [4:0]    exu_ard,
    input  [31:0]   exu_rd,
    input           exu_gen,

    input  [11:0]   exu_acsr,
    input  [31:0]   exu_csr,
    input           exu_sen,

    input           exu_write,
    input  [31:0]   exu_wdata,
    input  [31:0]   exu_addr,
    input  [1:0]    exu_mask, 
    input           exu_rsign,

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
    output [1:0]    lsu_wmask,

    output          reg_valid,
    output          csr_valid,
    output [31:0]   reg_data,
    output [31:0]   csr_data,
    output [4:0]    reg_addr,
    output [11:0]   csr_addr
);

//-----------------------------------------------------------------
// External Interface
//-----------------------------------------------------------------

    // lsu write
    assign lsu_wvalid   = wvalid;
    assign lsu_waddr    = waddr;
    assign lsu_wdata    = wdata;
    assign lsu_wmask    = wmask;

    // lsu read
    assign lsu_raddr    = ~rvalid & cah_valid ? cah_addr  : raddr;
    assign lsu_rvalid   = ~rvalid & cah_valid ? cah_valid : rvalid;
    assign lsu_rlen     = ~rvalid & cah_valid ? cah_rlen  : 8'b0;
    assign lsu_burst    = ~rvalid & cah_valid ? cah_burst : 1'b0;
    assign lsu_rmask    = ~rvalid & cah_valid ? 2'b11     : rmask;
    assign lsu_rsign    = ~rvalid & cah_valid ? 1'b0      : rsign;

    // write back
    assign exu_ready    = ~working & ~(cah_valid & exu_men & ~exu_write);
    assign reg_valid    = (rvalid   & lsu_rvalid & lsu_rready) |
                          (~exu_men & exu_ready  & exu_valid & exu_gen);
    assign reg_data     = rvalid ? lsu_rdata : exu_rd;
    assign reg_addr     = rvalid ? wbaddr    : exu_ard;
    
    assign csr_valid    = exu_ready & exu_valid & exu_sen;
    assign csr_data     = exu_csr;
    assign csr_addr     = exu_acsr;

    // cache inst fetch
    assign cah_ready    = ~rvalid & cah_valid ? lsu_rready   : 1'b0;
    assign cah_data     = ~rvalid & cah_valid ? lsu_rdata    : 0;

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------

    reg         working;

    reg         wvalid;
    reg [31:0]  waddr;
    reg [31:0]  wdata;
    reg [1:0]   wmask;

    reg         rvalid;
    reg [31:0]  raddr;
    reg [1:0]   rmask;
    reg         rsign;
    reg [4:0]   wbaddr;

    wire        wtok     = lsu_wready & lsu_wvalid;

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    // working
    always @(posedge clock) begin
        if (reset)
            working <= 1'b0;
        else if (exu_valid & exu_ready & exu_men)
            working <= 1'b1;
        else if (reg_valid | wtok)
            working <= 1'b0;
    end

    // memory write paramter copy
    always @(posedge clock) begin
        if (reset) begin
            waddr <= 0;
            wdata <= 0;
            wmask <= 2'b0;
        end
        else if (exu_valid & exu_ready & exu_men & exu_write) begin
            waddr <= exu_addr;
            wdata <= exu_wdata;
            wmask <= exu_mask;
        end
    end

    // wvalid
    always @(posedge clock) begin
        if (reset)
            wvalid <= 1'b0;
        else if (exu_valid & exu_ready & exu_men & exu_write)
            wvalid <= 1'b1;
        else if (wtok)
            wvalid <= 1'b0;
    end

    // memory ready paramter copy
    always @(posedge clock) begin
        if (reset) begin
            raddr <= 0;
            rmask <= 2'b0;
            rsign <= 1'b0;
            wbaddr <= 5'b0;
        end
        else if (exu_valid & exu_ready & exu_men & ~exu_write) begin
            raddr <= exu_addr;
            rmask <= exu_mask;
            rsign <= exu_rsign;
            wbaddr <= exu_ard;
        end
    end

    // rvalid
    always @(posedge clock) begin
        if (reset)
            rvalid <= 1'b0;
        else if (exu_valid & exu_ready & exu_men & ~exu_write)
            rvalid <= 1'b1;
        else if (lsu_rready & lsu_rvalid)
            rvalid <= 1'b0;
    end

endmodule
