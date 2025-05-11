module ysyx_25040111_adder32 (
    input [31:0] ina,
    input [31:0] inb,
    output [31:0] sout
);

    wire [7:0] cin;

    generate
        genvar i;
        for (i = 0; i < 8; i++) begin
            wire gcin = i == 0 ? 0 : cin[i - 1];
            ysyx_25040111_adder4 u_ysyx_25040111_adder4(
                .ina  	(ina[(4 * i + 3):(4 * i)]),
                .inb  	(inb[(4 * i + 3):(4 * i)]),
                .cin  	(gcin),
                .cout 	(cin[i]),
                .sout 	(sout[(4 * i + 3):(4 * i)])
            );
        end
    endgenerate

endmodule
