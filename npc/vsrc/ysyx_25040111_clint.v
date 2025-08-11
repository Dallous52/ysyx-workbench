`ifdef RUNSOC
`define CLINT_ADDR 32'h02000048
`else
`define CLINT_ADDR 32'ha0000048
`endif

module ysyx_25040111_clint(
    input           clock,
    input           reset,    

    input [31:0]    araddr,
    input           arvalid,
    output          arready,

    output [31:0]   rdata,
    output          rvalid,
    input           rready
);

    // time read
    reg [63:0] mtime;
    reg [31:0] tdata;
    reg        tvalid;

    assign arready = 1'b1;
    assign rvalid  = tvalid;
    assign rdata   = tdata;
    
    always @(posedge clock) begin
        mtime <= mtime + 1;

        if (reset)begin
            tdata <= 0;
            tvalid <= 1'b0;
        end        
        else if (arvalid & arready) begin
            tdata <= araddr == `CLINT_ADDR ? mtime[31:0] : mtime[63:32];
            tvalid <= 1; // 读取完毕
        end
        else if (rvalid & rready) begin
            tvalid <= 0;
        end
    end

endmodule
