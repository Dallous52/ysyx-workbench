module ysyx_25040111_ifu(
    input  [31:0] pc,
    output reg [31:0] inst,
    output valid
);

    always @(*) begin
        inst = pmem_read(pc);
    end

    assign valid = 1;

endmodule
