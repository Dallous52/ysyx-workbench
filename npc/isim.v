`timescale 1ns / 1ps

module isim();

  // 驱动信号
  reg clock;
  reg reset;

  // 生成时钟
  initial clock = 0;
  always #5 clock = ~clock; // 10ns周期 = 100MHz

  // 生成复位
  initial begin
    $display("start to reset...");
    reset = 1;
    #100;        // 100ns
    reset = 0;
  end

  ysyx_25040111 u_ysyx_25040111(
    .clock (clock),
    .reset (reset)
  );

  // 波形文件输出
  initial begin
    $dumpfile("waveform/isim.vcd");
    $dumpvars(0, isim);
  end

  // 仿真运行时间
    //   initial begin
    //     #20000; // 20us
    //     $finish;
    //   end

endmodule
