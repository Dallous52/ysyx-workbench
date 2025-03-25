module carry(
    input [3:0] p, 
    input [3:0] g,
    input cin,
    output [4:1] cout
);

    assign cout[1] = g[0] | (p[0] & cin);
    assign cout[2] = g[1] | (p[1] & g[0]) | (&p[1:0] & cin);
    assign cout[3] = g[2] | (p[2] & g[1]) | (&p[2:1] & g[0]) | (&p[2:0] & cin);
    assign cout[4] = g[3] | (p[3] & g[2]) | (&p[3:2] & g[1]) | (&p[3:1] & g[0]) | (&p[3:0] & cin);

endmodule


module adder(
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

    carry u_carry(
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
