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

    // ALU
    wire [31:0] res;
    ysyx_25040111_MuxKeyWithDefault #(5, 5, 32) temp_alu (res, opt[7:3], 32'b0, {
        5'b00000, imm,
        5'b00101, pc + imm,
        5'b00110, rs1_d + rs2_d,
        5'b00111, rs1_d + imm,
        5'b11000, pc + 4
    });
    
    // PC UPDATE
    ysyx_25040111_MuxKey #(4, 2, 32) dnpc_new(dnpc, opt[9:8], {
        2'b00, pc + 4, // WARNNING
        2'b01, pc + 4,
        2'b10, pc + imm,
        2'b11, rs1_d + imm
    });
    
    
    // ------------------------------------------------------- 
    //                        MEMORY
    // -------------------------------------------------------
    wire [7:0] wmask;
    ysyx_25040111_MuxKey #(4, 2, 8) wmask_c(wmask, opt[11:10], {
        2'b00, 8'h00,
        2'b01, 8'h01,
        2'b10, 8'h03,
        2'b11, 8'h0F
    });

    reg [31:0] rd_dt;
    always @(*) begin
        if (&opt[12:10]) begin  // 有读写请求时
            rd_dt = pmem_read(res);
            $display("[memory option]\n");
            if (~opt[12]) begin // 有写请求时
                pmem_write(res, rs2_d, wmask);
            end
        end
        else begin
            rd_dt = res;
        end
    end

    assign rd_d = rd_dt;

    
    // ------------------------------------------------------- 
    //                         SYSTEM
    // -------------------------------------------------------
    always @(*) begin
        if (opt == `EBREAK_INST)
            ebreak(rs1_d);
    end

endmodule
