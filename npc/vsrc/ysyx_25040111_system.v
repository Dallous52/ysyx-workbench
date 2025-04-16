import "DPI-C" function void ebreak();

module ysyx_25040111_system(
    input [31:0] inst
);

    always @(*) begin
        if (inst == 32'h00100073)
            ebreak();
    end

endmodule
