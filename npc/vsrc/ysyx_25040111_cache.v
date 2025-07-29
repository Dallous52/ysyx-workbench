module ysyx_25040111_cache(
    input   clock,
    input   reset,

    input   [31:0] addr,
    output  [31:0] data,
    
    output reg rstart,
    input   rok,
    input  [31:0] rdata,

    input   valid,
    output  ready
);

//-----------------------------------------------------------------
// Key Params
//-----------------------------------------------------------------
    
    parameter BLOCK_Ls = 2; // Byte len sqrt    4
    parameter CACHE_Ls = 4; // Block len sqrt   16

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------

    localparam TAG_IDX = BLOCK_Ls + CACHE_Ls;
    localparam TAG_HIG = 31 - TAG_IDX;

    localparam BLOCK_L = 2**BLOCK_Ls * 8;
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

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------

    reg [BLOCK_L-1 : 0] cblocks [CACHE_L-1 : 0];
    reg [TAG_HIG:0] ctags [CACHE_L-1 : 0];
    reg [CACHE_L-1 : 0] cvalids;

    wire hit = (ctags[index] == tag) & (cvalids[index]);

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    always @(posedge clock) begin
        if (reset) begin
            cdata <= 0;
            cready <= 0;
        end
        else if (valid & hit) begin
            cdata <= cblocks[index];
            cready <= 1'b1;
        end
        else if (rok) begin
            cdata <= rdata;
            cready <= 1'b1;
        end

        if (cready) cready <= 0;
    end

    always @(posedge clock) begin
        if (reset ) cvalids <= {CACHE_L{1'b0}};
        else if (valid & ~hit)
            rstart <= 1'b1;
        else if (rok) begin
            cblocks[index] <= rdata;
            ctags[index] <= tag;
            cvalids[index] <= 1;
        end

        if (rstart) rstart <= 1'b0;
    end

endmodule
