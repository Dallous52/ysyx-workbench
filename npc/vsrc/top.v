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

        assign seg1 = ans[3] ? 8'b11111101 : 8'b11111111;
        assign ledr[7:4] = ans;
    `endif

    // 4 位并行加法器
    `ifdef ADDER_M
        adder u_adder(
            .ina  	(sw[3:0]),
            .inb  	(sw[7:4]),
            .cin  	(sw[8]),
            .pf     (ledr[5]),
            .gf     (ledr[6]),
            .cout 	(ledr[4]),
            .sout 	(ledr[3:0])
        );
    `endif

    // 移位随机数发生器
    `ifdef RANDOM_M 
        reg [7:0] nums;
        initial begin
            nums = 8'b0;
        end
        
        always @(posedge btn[0]) begin
            if (|nums) begin
                
                nums <= {^nums[4:2] ^ nums[0], nums[7:1]};
            end
            else nums <= 8'b00000001;
        end
        
        segdis16 u_seg0(
            .num 	(nums[3:0]),
            .led 	(seg0)
        );
        
        segdis16 u_seg1(
            .num 	(nums[7:4]),
            .led 	(seg1)
        );

        assign ledr[7:0] = nums;
    `endif

    // 桶形移位器
    `ifdef SHIFT_M
        shiftor u_shiftor(
            .din   	(sw[7:0]    ),
            .shamt 	(sw[15:13]  ),
            .lr    	(sw[12]     ),
            .al    	(sw[11]     ),
            .dout  	(ledr[7:0]   )
        );
    `endif

endmodule
