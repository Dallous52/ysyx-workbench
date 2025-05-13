`include "ysyx_25040111_inc.vh"

import "DPI-C" function void ebreak(input int code);
import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);

module ysyx_25040111_exu(
    input [`OPT_HIGH:0] opt,
    input [31:0] rs1_d,
    input [31:0] rs2_d,
    input [31:0] imm,
    input [31:0] pc,
    output [31:0] rd_d,
    output [31:0] dnpc
);
    // ------------------------------------------------------- 
    //                        ALU
    // -------------------------------------------------------
    wire [31:0] res;
    wire [31:0] var1;
    wire [31:0] var2;
    ysyx_25040111_MuxKey #(4, 2, 64) c_alu_arg({var1, var2}, opt[4:3], {
        2'b00, {imm, 32'b0},
        2'b01, {pc, imm},
        2'b10, {rs1_d, rs2_d},
        2'b11, {rs1_d, imm}
    });

    ysyx_25040111_alu u_ysyx_25040111_alu(
        .var1 	(var1  ),
        .var2 	(var2  ),
        .opt  	(opt[7:5]   ),
        .snpc   (opt[12:10] == 3'b100),
        .ext    (opt[13]),
        .sign   (opt[14]),
        .negate (opt[15]),
        .res  	(res   )
    );
    
    // ------------------------------------------------------- 
    //                        PC UPDATE
    // -------------------------------------------------------
    wire [31:0] ina;
    wire [31:0] inb;
    wire [1:0] pc_ctl;
    
    assign pc_ctl = |opt[9:8] ? opt[9:8] : res[0] ? `INPC : `SNPC;
    ysyx_25040111_MuxKey #(4, 2, 64) c_pc_arg({ina, inb}, pc_ctl, {
        2'b00, 64'd0,
        2'b01, {pc, 32'd4},
        2'b10, {pc, imm},
        2'b11, {rs1_d, imm}
    });

    ysyx_25040111_adder32 u_ysyx_25040111_adder32(
        .ina  	    (ina   ),
        .inb  	    (inb   ),
        .sub        (0),
        .sout 	    (dnpc  ),
        .cout       (),
        .overflow   ()
    );
    
    
    // ------------------------------------------------------- 
    //                        MEMORY
    // -------------------------------------------------------
    wire [7:0] wmask;
    ysyx_25040111_MuxKey #(4, 2, 8) c_wmask(wmask, opt[11:10], {
        2'b00, 8'h00,
        2'b01, 8'h01,
        2'b10, 8'h03,
        2'b11, 8'h0F
    });

    reg [31:0] rd_dt;
    always @(*) begin
        if (|opt[11:10]) begin  // 有读写请求时
            $display("%x", res);
            rd_dt = pmem_read(res);
            if (~opt[12]) begin // 有写请求时
                pmem_write(res, rs2_d, wmask);
            end
        end
        else begin
            rd_dt = res;
        end
    end

    ysyx_25040111_MuxKey #(4, 2, 32) c_rdmem(rd_d, opt[11:10], {
        2'b00, res,
        2'b01, {{24{rd_dt[7] & opt[14]}}, rd_dt[7:0]},
        2'b10, {{16{rd_dt[15] & opt[14]}}, rd_dt[15:0]},
        2'b11, rd_dt
    });

    
    // ------------------------------------------------------- 
    //                         SYSTEM
    // -------------------------------------------------------
    wire [31:0] eret;
    assign eret = opt[15] ? rs1_d : 32'd9;
    always @(*) begin
        if (~(|opt[14:0]))
            ebreak(eret);
    end

endmodule
