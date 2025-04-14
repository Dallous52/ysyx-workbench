module ysyx_25040111_adder(
    input [3:0] ina,
    input [3:0] inb,
    input cin,
    output pf, 
    output gf,
    output cout,
    output [3:0] sout
);

    wire [3:0] p, g;
    wire [4:0] c;

    assign p = ina ^ inb;
    assign g = ina & inb;
    assign c[0] = cin;

    ysyx_25040111_carry u_carry(
        .p    	(p),
        .g    	(g),
        .cin    (cin),
        .cout 	(c[4:1])
    );

    assign cout = c[4];
    assign sout = p ^ c[3:0];
    assign pf = &p;
    assign gf = g[3] | (p[3] & g[2]) | (&p[3:2] & g[1]) | (&p[3:1] & g[0]);
    
endmodule
