`include "HDR/ysyx_25040111_dpic.vh"

module ysyx_25040111_cache(
    input           clock,
    input           reset,

    input   [31:0]  addr,       // 访问地址
    output  [31:0]  data,       // 返回数据
    
    output          chburst,    // 是否突发读取
    output reg      chvalid,    // 传输开始控制信号
    input           chready,    // 一次传输完成信号
    output [31:0]   chaddr,     // 访问地址
    output [7:0]    chlen,      // 访问次数
    input  [31:0]   chdata,     // 一次传输完成数据

    input           ifu_valid,  // 使能
    output          ifu_ready   // 完成
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

    wire [TAG_HIG:0]      tag    = addr[31:TAG_IDX]; 
    wire [CACHE_Ls-1 : 0] index  = addr[TAG_IDX-1 : BLOCK_Ls];
    wire [BLOCK_Ls-1 : 0] offset = addr[BLOCK_Ls-1 : 0];

    assign ifu_ready    = cready;
    assign data         = cdata;
    assign chlen        = DATA_L - 1;
    assign chaddr       = caddr;

`ifdef RUNSOC
    assign chburst      = addr[31:28] == 4'ha;        
`else
    assign chburst      = 1'b0;        
`endif

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------

    reg [BLOCK_L-1 : 0] cblocks [CACHE_L-1 : 0];
    reg [TAG_HIG:0]     ctags [CACHE_L-1 : 0];
    reg [CACHE_L-1 : 0] cvalids;

    reg [7:0]   count;
    reg [31:0]  caddr;
    reg         cready;
    reg [31:0]  cdata;

    wire        hit    = (ctags[index] == tag) & (cvalids[index]);
    wire        update = count == DATA_L;
    wire [31:0] naddr  = caddr + 4;
    wire        rend   = (count == DATA_L - 1) & chready & chvalid;
    
    wire [BLOCK_Ls+4 : 0] at = {5'b0 , offset >> 2};
    wire [BLOCK_L-1 : 0] tdata = {cblocks[index] >> (at << 5)};
    // wire [BLOCK_Ls-1 : 0]   at    = {offset >> 2};
    // wire [BLOCK_L-1 : 0]    tdata = at == {BLOCK_Ls{1'b0}} ? 
    //                                 cblocks[index] : {cblocks[index] >> 32};

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    // cdata
    always @(posedge clock) begin
        if (reset) begin
            cdata <= 0;
        end
        else if ((ifu_valid & hit & ~cready) | update) begin
        `ifndef YOSYS_STA
            if (ifu_valid & hit) cache_hit();
        `endif
            cdata <= tdata[31:0];
        end
    end

    // chvalid
    always @(posedge clock) begin
        if (reset)
            chvalid <= 1'b0;
        else if (ifu_valid & ~hit & ~chvalid)
            chvalid <= 1'b1;
        else if (rend)
            chvalid <= 1'b0;
    end

    // counter
    always @(posedge clock) begin
        if (reset) 
            count <= 8'b0;
        else if (chready) 
            count <= count + 1;
        else if (update)
            count <= 8'b0;
    end
    
    // main cache
    always @(posedge clock) begin
        if (reset) begin
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
                if (chready) cblocks[index] <= {chdata, cblocks[index][BLOCK_L-1:32]};
        end else begin
            always_ff @(posedge clock)
                if (chready) cblocks[index] <= chdata;
        end
    endgenerate

    // cready
    always @(posedge clock) begin
        if (reset)
            cready <= 1'b0;
        else if ((ifu_valid & hit & ~cready) | update)
            cready <= 1'b1;
        else
            cready <= 1'b0;
    end

    // caddr
    always @(posedge clock) begin
        if (reset)
            caddr <= 0;
        else if (ifu_valid & ~hit & ~chvalid)
            caddr <= {addr[31:BLOCK_Ls], {BLOCK_Ls{1'b0}}};
        else if (chready & ~chburst)
            caddr <= naddr;
        else if (rend)
            caddr <= 0;
    end

endmodule
