`include "../HDR/ysyx_25040111_inc.vh"

`define SYS_EBREAK 12'h001
`define SYS_ECALL  12'h000
`define SYS_MRET   12'h302

module ysyx_25040111_system(
    input [31:7] inst,
    output [4:0] rs1,
    output [4:0] rd,
    output reg [11:0] csr1, csr2,
    output [31:0] imm,
    output reg [`OPT_HIGH:0] opt
);
    wire [2:0] fun3;
    wire fix;
    reg [`OPT_HIGH:0] opt_t;

    assign fun3 = inst[14:12];
    assign rd = inst[11:7];
    assign fix = ~(|fun3);
    assign rs1 = fix ?  5'd10 : inst[19:15];
    assign imm = 32'b0;

    always @(*) begin
        case ({inst[31:20], fix})
            {`SYS_EBREAK, 1'b1}: begin
                csr1 = 12'b0;
                csr2 = 12'b0;
            end
            {`SYS_ECALL,  1'b1}: begin
                csr1 = `MEPC;
                csr2 = `MTVEC;
            end
            {`SYS_MRET,   1'b1}: begin
                csr1 = 12'b0;
                csr2 = `MEPC;
            end
            default: begin
                csr1 = inst[31:20];
                csr2 = inst[31:20];
            end
        endcase

        case (inst[31:20])
            `SYS_EBREAK: opt_t = `EBREAK_INST;
            `SYS_ECALL:  opt_t = `OPTG(`EMPTY, `PC_IM, `ADD, `JECALL, `WFS, `XXN);
            `SYS_MRET:   opt_t = `OPTG(`EMPTY, `EMP, `EMPTY, `EMP, `XFS, `XXN);
            default:     opt_t = `OPT_LEN'b0;
        endcase

        case (fun3)
            3'b000:  opt = opt_t;
            3'b001:  opt = `OPTG(`WFX, `RF_IM, `ADD,   `SNPC, `WFX, `XXN);
            3'b010:  opt = `OPTG(`WFX, `RF_RS, `AND,   `SNPC, `WFX, `EXN);
            default: opt = `OPT_LEN'b0;
        endcase
    end

    // ysyx_25040111_MuxKeyWithDefault #(3, 13, 12) csr_wc (csr1, {inst[31:20], fix}, inst[31:20], {
    //     {`SYS_EBREAk, 1'b1},    12'b0,
    //     {`SYS_ECALL,  1'b1},    `MEPC,
    //     {`SYS_MRET,   1'b1},    12'b0
    // });

    // ysyx_25040111_MuxKeyWithDefault #(3, 13, 12) csr_rc (csr2, {inst[31:20], fix}, inst[31:20], {
    //     {`SYS_EBREAk, 1'b1},    12'b0,
    //     {`SYS_ECALL,  1'b1},    `MTVEC,
    //     {`SYS_MRET,   1'b1},    `MEPC
    // });

    // ysyx_25040111_MuxKeyWithDefault #(3, 12, `OPT_LEN) opt_tc (opt_t, inst[31:20], `OPT_LEN'b0, {
    //     `SYS_EBREAk,    `EBREAK_INST,
    //     `SYS_ECALL,     `OPTG(`EMPTY, `PC_IM, `ADD, `JECALL, `WFS, `XXN),
    //     `SYS_MRET,      `OPTG(`EMPTY, `EMP, `EMPTY, `EMP, `XFS, `XXN)
    // });

    // ysyx_25040111_MuxKeyWithDefault #(3, 3, `OPT_LEN) opt_c (opt, fun3, `OPT_LEN'b0, {
    //     3'b000, opt_t,
    //     3'b001, `OPTG(`WFX, `RF_IM, `ADD, `SNPC, `WFX, `XXN),
    //     3'b010, `OPTG(`WFX, `RF_RS, `AND, `SNPC, `WFX, `EXN)
    // });

endmodule
