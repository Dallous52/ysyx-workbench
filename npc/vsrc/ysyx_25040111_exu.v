`include "HDR/ysyx_25040111_inc.vh"
`include "HDR/ysyx_25040111_dpic.vh"
`include "ALU/ysyx_25040111_alu.v"

module ysyx_25040111_exu(
    input                   clock,
    input                   reset,
    
    input                   exe_valid,
    output                  exe_ready,
    input  [`OPT_HIGH:0]    opt,
    input  [4:0]            ard_in,
    input  [11:0]           acsrd_in,
    input  [31:0]           pc,
    input  [31:0]           imm,
    
    input  [31:0]           csri,
    input  [31:0]           rs1,
    input  [31:0]           rs2,

    output                  abt_valid,
    input                   abt_ready,
    output                  abt_men,

    output [4:0]            abt_ard,
    output [31:0]           abt_rd,
    output                  abt_gen,

    output [11:0]           abt_acsr,
    output [31:0]           abt_csr,
    output                  abt_sen,

    output                  abt_write,
    output [31:0]           abt_wdata,
    output [31:0]           abt_addr,
    output [1:0]            abt_mask, 
    output                  abt_rsign,
    
    output [31:0]           jump_pc,
    output reg              jpc_ready
);

//-----------------------------------------------------------------
// External Interface
//-----------------------------------------------------------------
    
    assign exe_ready = ~exe_ok;
    assign abt_valid = exe_ok;
    assign abt_men   = |abt_mask & ~eopt[15];

    assign abt_ard   = ard;
    assign abt_rd    = mwt ? csri : rd;
    assign abt_gen   = eopt[0];

    assign abt_acsr  = acsrd;
    assign abt_csr   = rd;
    assign abt_sen   = mwt;

    assign abt_rsign = eopt[14];
    assign abt_write = ~eopt[12];
    assign abt_addr  = rd;
    assign abt_wdata = rs2;
    assign abt_mask  = eopt[11:10];

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------
    
    reg [31:0]          var1, var2; // alu args
    reg [31:0]          arg1, arg2; // pc  args
    reg [4:0]           ard;
    reg [11:0]          acsrd;
    reg                 exe_ok;

    reg [`OPT_HIGH: 0]  eopt;
    reg [4:0]           rlock;
    
    wire[31:0]          rd;

    wire snpc = opt[12:10] == 3'b100;
    wire mtp  = opt[12]     & opt[15];
    wire mrd  = opt[15]     & opt[11];
    wire mwt  = eopt[15]    & eopt[10];

    wire jmp  = ~((opt[9:8] == 2'b01) & |opt[2:0]) | (opt[12] & opt[15]);

//-----------------------------------------------------------------
// MODULE INSTANCES
//-----------------------------------------------------------------

    // ALU
    ysyx_25040111_alu u_alu(
        .var1 	(var1       ),
        .var2 	(var2       ),
        .opt  	(eopt[7:5]  ),
        .snpc   (snpc       ),
        .ext    (eopt[13]   ),
        .sign   (eopt[14]   ),
        .negate (eopt[15]   ),
        .res  	(rd         )
    );

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    // jpc_ready
    always @(posedge clock) begin
        if (reset)
            jpc_ready <= 1'b0;
        else if (exe_ready & exe_valid & jmp)
            jpc_ready <= 1'b1;
        else
            jpc_ready <= 1'b0;
    end

    // exe_ok
    always @(posedge clock) begin
        if (reset)
            exe_ok <= 1'b0;
        else if (exe_ready & exe_valid)
            exe_ok <= 1'b1;
        else if (abt_ready & abt_valid)
            exe_ok <= 1'b0;
    end

    // ard acsrd eopt
    always @(posedge clock) begin
        if (reset) begin
            eopt <= 0;
            ard <= 5'b0;
            acsrd <= 12'b0;
        end
        else if (exe_ready & exe_valid) begin
            ard <= ard_in;
            acsrd <= acsrd_in;
            eopt <= opt;
        end
    end

    // alu var1 var2
    always @(posedge clock) begin
        if (reset) begin
            var1 <= 0;
            var2 <= 0;
        end
        else if (exe_ready & exe_valid) begin
            case (opt[4:3])
                2'b00: begin var1 <= imm; var2 <= 0;    end
                2'b01: begin var1 <= pc;  var2 <= imm;  end
                2'b10: begin 
                    var1 <= rs1; 
                    var2 <= mrd ? csri : rs2; 
                end
                2'b11: begin var1 <= rs1; var2 <= imm;  end
            endcase
        end
    end

    // pc arg1 arg2
    always @(posedge clock) begin
        if (reset) begin
            arg1 <= 0;
            arg2 <= 0;
        end
        else if (jpc_ready) begin
            case (eopt[9:8])
                2'b00: begin 
                    arg1 <= mtp ? csri  : pc;  
                    arg2 <= mtp ? 32'd0 : rd[0] ? imm : 32'd4;  
                end
                2'b01: begin arg1 <= pc;  arg2 <= 32'd4;  end
                2'b10: begin arg1 <= pc;  arg2 <= imm;    end
                2'b11: begin arg1 <= rs1; arg2 <= imm;    end
            endcase
        end
    end

//-----------------------------------------------------------------
// Combinational Logic
//-----------------------------------------------------------------

    assign jump_pc = arg1 + arg2;

`ifndef YOSYS_STA
    // EBREADK
    wire [31:0] eret;
    assign eret = opt[15] ? rs1 : 32'd9;
    always @(*) begin
        if (opt == `EBREAK_INST)
            ebreak(eret);
    end
`endif // YOSYS_STA

endmodule
