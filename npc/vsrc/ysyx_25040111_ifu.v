module ysyx_25040111_ifu(
    input [31:0] pc,
    output [31:0] inst,
    output valid
);

    always @(*) begin
        inst = pmem_read(pc);
        valid = 1;
    end

endmodule
