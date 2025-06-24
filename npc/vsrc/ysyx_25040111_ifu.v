import "DPI-C" function int pmem_read(input int raddr);

module ysyx_25040111_ifu (
    input  clk,
    input  ready,
    input  [31:0] pc,
    output reg [31:0] inst,
    output reg valid
);

    always @(posedge clk) begin
        if (ready) begin
            inst  <= pmem_read(pc);
            valid <= 1;
        end
        else begin
            valid <= 0;
        end
    end

endmodule
