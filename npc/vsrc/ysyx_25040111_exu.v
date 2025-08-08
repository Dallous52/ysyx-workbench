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

    output                  reg_ready,
    output                  csr_ready,
    output [4:0]            ardo,
    output [11:0]           acsro,
    output [31:0]           csro,
    output [31:0]           rdo,

    output [31:0]           jump_pc,
    output                  jpc_ready,

    input                   wready,
    output                  wvalid,
    output [31:0]           wdata,
    output [31:0]           waddr,
    output [1:0]            wmask, 

    input                   rready,
    output                  rvalid,
    output [31:0]           raddr,
    output [4:0]            wbaddr,
    output [1:0]            rmask,
    output                  rsign
);

//-----------------------------------------------------------------
// External Interface
//-----------------------------------------------------------------
    
    assign exe_ready = ~exe_ok;
    assign jpc_ready = exe_ok;

    assign ardo      = ard;
    assign rdo       = mwt ? csri : rd;
    assign reg_ready = exe_ok & eopt[0];

    assign acsro     = acsrd;
    assign csro      = rd;
    assign csr_ready = exe_ok & mwt;

    assign rsign     = eopt[14];

//-----------------------------------------------------------------
// Register / Wire
//-----------------------------------------------------------------
    
    reg [31:0]  var1, var2; // alu args
    reg [31:0]  arg1, arg2; // pc  args
    reg [4:0]   ard;
    reg [11:0]  acsrd;
    reg         exe_ok;

    reg [`OPT_HIGH: 0] eopt;
    reg [4:0]          rlock;

    wire snpc = opt[12:10] == 3'b100;
    wire mtp  = opt[12]  & opt[15];
    wire mrd  = opt[15]  & opt[11];
    wire mwt  = eopt[15] & eopt[10];

    wire [31:0] rd;

//-----------------------------------------------------------------
// MODULE INSTANCES
//-----------------------------------------------------------------

    // ALU
    ysyx_25040111_alu u_alu(
        .var1 	(var1       ),
        .var2 	(var2       ),
        .opt  	(opt[7:5]   ),
        .snpc   (snpc       ),
        .ext    (opt[13]    ),
        .sign   (opt[14]    ),
        .negate (opt[15]    ),
        .res  	(rd         )
    );

//-----------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------

    // exe_ok
    always @(posedge clock) begin
        if (reset)
            exe_ok <= 1'b0;
        else if (exe_ready & exe_valid)
            exe_ok <= 1'b1;
        else if ()
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
            var1 = 0;
            var2 = 0;
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
        else if (exe_ready & exe_valid) begin
            case (opt[9:8])
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
