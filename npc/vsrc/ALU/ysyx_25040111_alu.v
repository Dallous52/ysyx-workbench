`ifndef NPC_ALU
`define NPC_ALU 

`include "../ysyx_25040111_MuxKey.v"

module ysyx_25040111_alu (
    input [31:0] var1,
    input [31:0] var2,
    input [2:0] opt,
    input snpc,
    input ext,
    input sign,
    input negate,
    output [31:0] res
);

    wire [31:0] res_add;
    wire [31:0] vart, dxor;
    wire overflow, cout, lt;

    assign vart = snpc ? 32'd4 : var2;

    ysyx_25040111_adder32 u_adder32(
        .ina  	    (var1   ),
        .inb  	    (vart   ),
        .sub        (ext),
        .sout 	    (res_add),
        .overflow   (overflow),
        .cout       (cout)
    );

    assign dxor = (var1 ^ var2);
    assign lt = sign ? res_add[31] ^ overflow : ~cout;
    wire signed [31:0] shiftrl;

    assign shiftrl = $signed({var1[31] & sign, 31'b0}) >>> var2[4:0];

    ysyx_25040111_MuxKey #(8, 3, 32) c_alu (res, opt, {
        3'b000, var1,
        3'b001, res_add, 
        3'b010, ext ? (var1 | var2) : (var1 & var2),
        3'b011, dxor,
        3'b100, var1 << var2[4:0],
        3'b101, (var1 >> var2[4:0]) | shiftrl,
        3'b110, {31'b0, lt ^ negate},
        3'b111, {31'b0, (~(|dxor)) ^ negate}
    });
    
endmodule

`endif
