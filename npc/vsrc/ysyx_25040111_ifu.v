`include "HDR/ysyx_20540111_dpic.vh"

module ysyx_25040111_ifu (
    input  clk,
    input  reset,
    input  ready,
    output reg if_start,
    output reg if_flag,
    input [31:0] inst_t,
    output reg [31:0] inst,
    input if_ok,
    output reg valid
);

    always @(posedge clk) begin
        // $display("pc:%h  vaild:%b  ready:%b", pc, valid, ready);
        // if (ready) begin
        //     inst <= pmem_read(pc);
        //     valid <= 1;
        // end
        // else begin
        //     inst <= inst;
        // end

        // if (valid)
        //     valid <= 0;
        if (reset) begin
            if_flag <= 0;
            if_start <= 0;
        end
        else if (ready) begin 
            if_flag <= 1;
            if_start <= 1;
        end

        if (if_start) if_start <= 0;

        if (if_ok) begin
            inst <= inst_t;
            if_flag <= 0;
            valid <= 1;
        `ifdef PMC_EN
            monitor_counter(`IFU);            
        `endif
        end
        else inst <= inst;

        if (valid)
            valid <= 0;
    end

`ifdef PMC_EN
    always @(*) begin
        if (if_ok) begin
            case (inst[6:0])
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
