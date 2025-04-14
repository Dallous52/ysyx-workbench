module ysyx_25040111_opimm (
    input [31:0] inst,
    output [4:0] rs1,
    output [31:0] wdata,
    output [4:0] waddr
);

    wire en;
    wire [11:0] imm;
    wire [4:0] rd;
    wire [2:0] fun3;

    assign {imm, rs1, fun3, rd} = inst[31:7];
    assign en = inst[6:0] == 7'b0010011;

    wire [31:0] wdata_addi;
    wire [4:0] waddr_addi;
    ysyx_25040111_opimm_addi u_ysyx_25040111_opimm_addi(
        .en    	(fun3 == 3'b000),
        .imm   	(imm    ),
        .rd    	(rd     ),
        .wdata 	(wdata_addi  ),
        .waddr 	(waddr_addi  )
    );
    
    assign waddr = en ? waddr_addi : 5'b00000;
    assign wdata = en ? wdata_addi : 32'd0;

endmodule
