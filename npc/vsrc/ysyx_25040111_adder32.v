module ysyx_25040111_adder32 (
    input [31:0] ina,
    input [31:0] inb,
    input sub,
    output [31:0] sout,
    output over
);

    wire [7:0] cin;
    wire [31:0] inbt;
    assign inbt = sub ? ~inb : inb;

    generate
        genvar i;
        for (i = 0; i < 8; i++) begin
            wire gcin = i == 0 ? sub : cin[i - 1];
            ysyx_25040111_adder4 u_ysyx_25040111_adder4(
                .ina  	(ina[(4 * i + 3):(4 * i)]),
                .inb  	(inbt[(4 * i + 3):(4 * i)]),
                .cin  	(gcin),
                .cout 	(cin[i]),
                .sout 	(sout[(4 * i + 3):(4 * i)])
            );
        end
    endgenerate

    assign over = cin[7];

endmodule
