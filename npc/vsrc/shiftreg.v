module chos(
    input  x0,
    input  x1,
    input  x2,
    input  x3,
    input [1:0] y,
    output reg f
);
    // 4 选 1 选择器逻辑
    always @(*) begin
        case (y)
            2'b00: f = x0;
            2'b01: f = x1;
            2'b10: f = x2;
            2'b11: f = x3;
            default: f = 1'b0;
        endcase
    end

endmodule    

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

    // 第一层
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
    
    // 第二层
    generate
        genvar j;
        for (j = 0; j < 8; j = j + 1) begin
            wire jxl = j > 6 ? lv2[9] : lv2[j + 3];
            wire jx3 = j < 1 ? lv2[0] : lv2[j - 1];
            chos u_chos(
                .x0 	(lv2[j + 1]),
                .x1 	(jxl),
                .x2 	(lv2[j + 1]),
                .x3 	(jx3),
                .y  	({shamt[1], lr}),
                .f  	(lv3[j + 1])
            );
        end
    endgenerate

    // 第三层
    generate
        genvar k;
        for (k = 0; k < 8; k = k + 1) begin
            wire kxl = k > 4 ? lv3[9] : lv3[k + 5];
            wire kx3 = k < 3 ? lv3[0] : lv3[k - 3];
            chos u_chos(
                .x0 	(lv3[k + 1]),
                .x1 	(kxl),
                .x2 	(lv3[k + 1]),
                .x3 	(kx3),
                .y  	({shamt[2], lr}),
                .f  	(dout[k])
            );
        end
    endgenerate

endmodule
