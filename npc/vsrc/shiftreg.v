`include "choose.v"

module shiftreg(
    input [7:0] din,
    input [2:0] shamt,
    input lr, // 左1 右0
    input al, // 逻辑0 算数1
    output [7:0] dout
);
    
    wire [9:0] lv1, lv2, lv3;
    wire csal;

    assign csal = al ? din[7] : 1'b0;
    assign lv1 = {csal, din, 1'b0};
    assign lv2[0] = 1'b0;
    assign lv2[9] = csal;
    assign lv3[0] = 1'b0;
    assign lv3[9] = csal;

    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin
            chos u_chos(
                .x0 	(din[i]),
                .x1 	(lv1[i + 2]),
                .x2 	(din[i]),
                .x3 	(lv1[i]),
                .y  	({shamt[0], lr}),
                .f  	(lv2[i + 1])
            );
        end
    endgenerate
    
    generate
        for (i = 0; i < 8; i = i + 1) begin
            wire xl = i > 6 ? lv2[9] : lv2[i + 3];
            wire x3 = i < 1 ? lv2[0] : lv2[i - 1];
            chos u_chos(
                .x0 	(lv2[i + 1]),
                .x1 	(xl),
                .x2 	(lv2[i + 1]),
                .x3 	(x3),
                .y  	({shamt[1], lr}),
                .f  	(lv3[i + 1])
            );
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i + 1) begin
            wire xl = i > 4 ? lv2[9] : lv3[i + 5];
            wire x3 = i < 3 ? lv2[0] : lv3[i - 3];
            chos u_chos(
                .x0 	(lv3[i + 1]),
                .x1 	(xl),
                .x2 	(lv3[i + 1]),
                .x3 	(x3),
                .y  	({shamt[2], lr}),
                .f  	(dout[i])
            );
        end
    endgenerate

endmodule
