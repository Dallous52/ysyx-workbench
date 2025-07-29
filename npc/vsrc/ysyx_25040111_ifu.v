`include "HDR/ysyx_25040111_dpic.vh"

module ysyx_25040111_ifu (
    input  clk,
    input  reset,
    input  ready,
    output reg start,
    output reg if_flag,
    input [31:0] inst_t,
    output reg [31:0] inst,
    input if_ok,
    output reg valid
);

    always @(posedge clk) begin
        if (reset) begin
            if_flag <= 0;
            start <= 0;
        end
        else begin
            if (ready) begin
                if_flag <= 1;
                start <= 1;    
            end 
            if (start) start <= 0;

            if (if_ok) begin
                inst <= inst_t;
                if_flag <= 0;
                valid <= 1;
            end
            else inst <= inst;

            if (valid)
                valid <= 0;
        end
    end

`ifdef PMC_EN
    always @(posedge clk) begin
        if (if_ok) begin
            case (inst_t[6:0])
                7'b0010011: monitor_counter(`IOPT);            
                7'b0010111: monitor_counter(`IOPT);            
                7'b0110111: monitor_counter(`IOPT);            
                7'b1100111: monitor_counter(`IJUMP);            
                7'b1101111: monitor_counter(`IJUMP);            
                7'b1110011: monitor_counter(`ICSR);            
                7'b0100011: monitor_counter(`IMEM);            
                7'b0000011: monitor_counter(`IMEM);            
                7'b0110011: monitor_counter(`IOPT);            
                7'b1100011: monitor_counter(`IJUMP);            
                default: ;
            endcase
        end
    end
`endif

endmodule
