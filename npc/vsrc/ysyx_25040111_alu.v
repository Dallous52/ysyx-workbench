module ysyx_25040111_alu (
    input [31:0] var1,
    input [31:0] var2,
    input [2:0] opt,
    output [31:0] res
);

    wire [31:0] res_add;
    wire [31:0] vart;

    assign vart = &opt ? 32'd4 : var2;

    ysyx_25040111_adder32 u_adder32(
        .ina  	(var1   ),
        .inb  	(vart   ),
        .sout 	(res_add)
    );
    

    ysyx_25040111_MuxKey #(8, 3, 32) c_alu (res, opt, {
        3'b000, var1,
        3'b001, res_add,
        3'b010, var1 & var2,
        3'b011, var1 | var2,
        3'b100, var1 ^ var2,
        3'b101, var1 << var2,
        3'b110, var1 >> var2,
        3'b111, res_add
    });
    
endmodule
