module ysyx_25040111_alu (
    input [31:0] var1,
    input [31:0] var2,
    input [2:0] opt,
    input snpc,
    input ext,
    output [31:0] res
);

    wire [31:0] res_add;
    wire [31:0] vart, dxor;
    wire over;

    assign vart = snpc ? 32'd4 : var2;

    ysyx_25040111_adder32 u_adder32(
        .ina  	(var1   ),
        .inb  	(vart   ),
        .sub    (ext),
        .sout 	(res_add),
        .over   (over)
    );

    assign dxor = (var1 ^ var2);

    ysyx_25040111_MuxKey #(8, 3, 32) c_alu (res, opt, {
        3'b000, var1,
        3'b001, res_add,
        3'b010, ext ? (var1 | var2) : (var1 & var2),
        3'b011, dxor,
        3'b100, var1 << var2,
        3'b101, var1 >> var2,
        3'b110, {31'b0, over},
        3'b111, {31'b0, ~(|dxor)}
    });
    
endmodule
