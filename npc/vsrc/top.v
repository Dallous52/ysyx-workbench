module top(
    input clk,
    input rst,
    input [4:0] btn,
    input [15:0] sw,
    input ps2_clk,
    input ps2_data,
    input uart_rx,
    output uart_tx,
    output [15:0] ledr,
    output VGA_CLK,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output [7:0] seg0,
    output [7:0] seg1,
    output [7:0] seg2,
    output [7:0] seg3,
    output [7:0] seg4,
    output [7:0] seg5,
    output [7:0] seg6,
    output [7:0] seg7
);
  
    // 双控开关模块
    `ifdef DUALCTL_M 
        dualctl u_dualctl(
          .a 	(sw[0]  ),
          .b 	(sw[1]  ),
          .f 	(ledr[0])
        );  
    `endif
    
    // 2位4选1选择器
    `ifdef CHOOSE_M
        choose u_choose(
            .x0 	(sw[3:2]),
            .x1 	(sw[5:4]),
            .x2 	(sw[7:6]),
            .x3 	(sw[9:8]),
            .y  	(sw[1:0]),
            .f  	(ledr[1:0])
        );
    `endif

    // 8-3 优先编码器
    `ifdef ENCODE_M
        encode u_encode(
            .src  	(sw[7:0]),
            .en   	(sw[8]),
            .isin 	(ledr[4]),
            .led  	(seg0),
            .ret  	(ledr[2:0])
        );
    `endif

    // ALU
    `ifdef ALU_M  
        reg [3:0] ans;
        
        alu u_alu(
            .arga  	(sw[3:0]),
            .argb  	(sw[7:4]),
            .opt   	(sw[10:8]),
            .res   	(ans),
            .zero  	(ledr[0]),
            .ovfl  	(ledr[1]),
            .carry 	(ledr[2])
        );

        segdis u_seg0(
            .num 	(ans[2:0]),
            .led 	(seg0)
        );

        assign seg2 = ans[3] ? 8'b00000001 : 8'b11111101;
    `endif

endmodule
