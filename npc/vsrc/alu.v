module alu(
    input [3:0] arga,
    input [3:0] argb,
    input [2:0] opt,
    output reg [3:0] res,
    output reg zero,
    output reg ovfl,
    output reg carry
);
    reg [3:0] cura, curb;
    reg [3:0] tmp, ans;

    always @(*) begin
        // 补码计算
        cura = arga[3] == 0 ? arga : ({arga[3], ~arga[2:0]} + 4'b0001);
        curb = argb[3] == 0 ? argb : ({argb[3], ~argb[2:0]} + 4'b0001);
        carry = 0;
        ovfl = 0;
        tmp = 0;
        ans = 0;

        case (opt)
            3'b000: begin
                {carry, ans} = cura + curb;
                ovfl = (cura[3] == curb[3]) && (ans[3] != cura[3]);
                res = ans[3] == 0 ? ans : {ans[3], ~(ans[2:0] - 3'b001)};
            end
    
            3'b001: begin
                // b -> -b
                tmp = ~curb + 4'b0001;
                {carry, ans} = cura + tmp;
                ovfl = (cura[3] == tmp[3]) && (ans[3] != cura[3]);
                res = ans[3] == 0 ? ans : {ans[3], ~(ans[2:0] - 3'b001)};
            end

            3'b010: begin
                res = ~cura;
            end

            3'b011: begin
                res = cura & curb;
            end

            3'b100: begin
                res = cura | curb;
            end

            3'b101: begin
                res = cura ^ curb;
            end

            3'b110: begin
                res = {3'b000, cura < curb};
            end

            3'b111: begin
                res = {3'b000, cura == curb};
            end
        endcase
    end

    assign zero = ~(|res);

endmodule
