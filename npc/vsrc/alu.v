module adder(
    input [3:0] arga,
    input [3:0] argb,
    output [3:0] res,
    output ovfl,
    output carry
);

    // 加法运算
    assign {carry, res} = arga + argb;
    
    // 进位判断
    assign ovfl = (arga[2] == argb[2]) && (res[2] != arga[2]);
    
endmodule //adder


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

    assign cura = arga[3] == 0 ? arga : ({arga[3], ~arga[2:0]} + 4'b0001);
    assign curb = argb[3] == 0 ? argb : ({argb[3], ~argb[2:0]} + 4'b0001);

    always @(cura, curb, opt) begin
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
                res = {2'b00, cura < curb};
            end

            3'b111: begin
                
            end 
        endcase
        res = res[3] == 0 ? res : {res[3], ~(res[2:0] - 3'b001)};
    end

    assign zero = ~(|res);

endmodule
