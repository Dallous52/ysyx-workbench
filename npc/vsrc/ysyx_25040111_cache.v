`include "HDR/ysyx_25040111_dpic.vh"

module ysyx_25040111_cache(
    input   clock,
    input   reset,

    input   [31:0] addr,    // 访问地址
    input   rburst,         // 是否突发读取
    output  [31:0] data,    // 返回数据
    
    output reg      rstart, // 传输开始控制信号
    output [31:0]   raddr,  // 访问地址
    output [7:0]    rlen,   // 访问次数
    input           rok,    // 一次传输完成信号
    input  [31:0]   rdata,  // 一次传输完成数据

    input   valid,          // 使能
    output  ready           // 完成
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
    assign rlen = rburst ? DATA_L - 1 : 8'b0;
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
    wire [BLOCK_L-1 : 0] tdata = {cblocks[index] >> (at << 5)};

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
            cdata <= tdata[31:0];
        end
    end

    // rstart
    always @(posedge clock) begin
        if (reset)
            rstart <= 1'b0;
        else if (valid & ~hit)
            rstart <= 1'b1;
        else if (~update & rok & (count != DATA_L - 1) & ~rburst)
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
        else if (rok & ~rburst)
            caddr <= caddr + 4;
        else if (update)
            caddr <= 0;
    end

endmodule
