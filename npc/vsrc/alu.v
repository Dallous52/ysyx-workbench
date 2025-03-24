module alu(
    input [3:0] arga,
    input [3:0] argb,
    input [2:0] opt,
    output reg [3:0] res,
    output reg zero,
    output reg ovfl,
    output reg carry
);
    reg [3:0] cura;
    reg [3:0] curb;

    always @(cura, curb, opt) begin
        cura = arga[3] == 0 ? arga : ({arga[3], ~arga[2:0]} + 4'b0001);
        curb = argb[3] == 0 ? argb : ({argb[3], ~argb[2:0]} + 4'b0001);

        case (opt)
            3'b000: begin 
                {carry, res} = cura + curb;
                ovfl = (cura[3] == curb[3]) && (res[3] != cura[3]);
            end
            
            3'b001: begin
                curb = ~curb + 4'b0001;
                {carry, res} = cura + curb;
                ovfl = (cura[3] == curb[3]) && (res[3] != cura[3]);
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
        res = res[3] == 0 ? res : {res[3], ~(res[2:0] - 3'b001)};
    end

    assign zero = ~(|res);

endmodule
