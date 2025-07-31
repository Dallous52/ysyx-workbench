`include "HDR/ysyx_25040111_dpic.vh"

module ysyx_25040111_cache(
    input   clock,
    input   reset,

    input   [31:0] addr,
    output  [31:0] data,
    
    output reg      rstart,
    output [31:0]   raddr,
    output [7:0]    rlen,
    input           rok,
    input  [31:0]   rdata,

    input   valid,
    output  ready
);

//-----------------------------------------------------------------
// Key Params
//-----------------------------------------------------------------
    
    parameter CACHE_Ls = 4; // Block len sqrt   16
    parameter BLOCK_Ls = 2; // Byte len sqrt    4

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------

    localparam TAG_IDX = BLOCK_Ls + CACHE_Ls;
    localparam TAG_HIG = 31 - TAG_IDX;

    localparam BLOCK_L = 2**BLOCK_Ls << 3;
    localparam DATA_L  = 2**BLOCK_Ls >> 2;
    localparam CACHE_L = 2**CACHE_Ls;

//-----------------------------------------------------------------
// External Interface
//-----------------------------------------------------------------

    wire [TAG_HIG:0] tag = addr[31:TAG_IDX]; 
    wire [CACHE_Ls-1 : 0] index = addr[TAG_IDX-1 : BLOCK_Ls];
    wire [BLOCK_Ls-1 : 0] offset = addr[BLOCK_Ls-1 : 0];

    reg cready;
    reg [31:0] cdata;

    assign ready = cready;
    assign data = cdata;
    assign rlen = DATA_L - 1;
    assign raddr = caddr;

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------

    reg [BLOCK_L-1 : 0] cblocks [CACHE_L-1 : 0];
    reg [TAG_HIG:0] ctags [CACHE_L-1 : 0];
    reg [CACHE_L-1 : 0] cvalids;
    reg [7:0] count;
    reg [31:0] caddr;

    wire hit = (ctags[index] == tag) & (cvalids[index]);
    wire update = count == DATA_L;
    wire [BLOCK_Ls+4 : 0] at = {5'b0 , offset >> 2};

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    // cdata
    always @(posedge clock) begin
        if (reset) begin
            cdata <= 0;
        end
        else if ((valid & hit) | update) begin
        `ifndef YOSYS_STA
            if (valid & hit) cache_hit();
        `endif
            cdata <= {cblocks[index] >> (at << 5)}[31:0];
        end
    end

    // rstart
    always @(posedge clock) begin
        if (reset)
            rstart <= 1'b0;
        else if (valid & ~hit)
            rstart <= 1'b1;
        else if (~update & rok & (count != DATA_L - 1))
            rstart <= 1'b1;
        else
            rstart <= 1'b0;
    end

    // counter
    always @(posedge clock) begin
        if (reset) 
            count <= 8'b0;
        else if (rok) 
            count <= count + 1;
        else if (update)
            count <= 8'b0;
    end
    
    // main cache
    always @(posedge clock) begin
        if (reset ) begin
            cvalids <= {CACHE_L{1'b0}};
        end
        else if (update) begin
            ctags[index] <= tag;
            cvalids[index] <= 1'b1;    
        end
    end
    generate
        if (BLOCK_L > 32) begin
            always_ff @(posedge clock) 
                if (rok) cblocks[index] <= {rdata, cblocks[index][BLOCK_L-1:32]};
        end else begin
            always_ff @(posedge clock)
                if (rok) cblocks[index] <= rdata;
        end
    endgenerate

    // cready
    always @(posedge clock) begin
        if (reset)
            cready <= 1'b0;
        else if ((valid & hit) | update)
            cready <= 1'b1;
        else
            cready <= 1'b0;
    end

    // caddr
    always @(posedge clock) begin
        if (reset)
            caddr <= 0;
        else if (valid & ~hit)
            caddr <= {addr[31:BLOCK_Ls], {BLOCK_Ls{1'b0}}};
        else if (rok)
            caddr <= caddr + 4;
        else if (update)
            caddr <= 0;
    end

endmodule
