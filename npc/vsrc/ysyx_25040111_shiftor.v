module ysyx_25040111_shiftor(
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
            ysyx_25040111_MuxKey #(4, 2, 1) i0 (lv2[i + 1], {lr, shamt[0]}, {
                2'b00, din[i],
                2'b01, lv1[i + 2],
                2'b10, din[i],
                2'b11, lv1[i]
            });
        end
    endgenerate
    
    // 第二层
    generate
        genvar j;
        for (j = 0; j < 8; j = j + 1) begin
            wire jxl = j > 6 ? lv2[9] : lv2[j + 3];
            wire jx3 = j < 1 ? lv2[0] : lv2[j - 1];
            ysyx_25040111_MuxKey #(4, 2, 1) i0 (lv3[j + 1], {lr, shamt[1]}, {
                2'b00, lv2[i + 1],
                2'b01, jxl,
                2'b10, lv2[j + 1],
                2'b11, jx3
            });
        end
    endgenerate

    // 第三层
    generate
        genvar k;
        for (k = 0; k < 8; k = k + 1) begin
            wire kxl = k > 4 ? lv3[9] : lv3[k + 5];
            wire kx3 = k < 3 ? lv3[0] : lv3[k - 3];
            ysyx_25040111_MuxKey #(4, 2, 1) i0 (dout[k], {lr, shamt[2]}, {
                2'b00, lv3[k + 1],
                2'b01, kxl,
                2'b10, lv3[k + 1],
                2'b11, kx3
            });
        end
    endgenerate

endmodule
