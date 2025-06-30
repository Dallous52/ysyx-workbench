`include "HDR/ysyx_20540111_dpic.vh"

module ysyx_25040111_ifu (
    input  clk,
    input  ready,
    input  [31:0] pc,
    output reg [31:0] inst,
    output reg valid
);

    always @(*) begin
        // $display("pc:%h  vaild:%b  ready:%b", pc, valid, ready);
        // if (ready) begin
            inst  = pmem_read(pc);
        // end
        // else begin
        //     inst <= inst;    
        // end

        // if (valid)
        //     valid <= 0;
    end

endmodule
