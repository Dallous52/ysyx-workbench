`include "include/tpdef.vh" 

module top(
    input clk,
    input [31:0] inst,
    output [31:0] pc
);
   
   RegisterFile u_RegisterFile(
    .clk   	(clk    ),
    .wen   	(wen    ),
    .wdata 	(wdata  ),
    .waddr 	(waddr  ),
    .raddr 	(raddr  ),
    .rdata 	(rdata  )
   );
   
    
    

endmodule
