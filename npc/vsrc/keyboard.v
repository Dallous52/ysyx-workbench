module ps2_keyboard(
    input clk,          // 系统主时钟
    input clrn,         // 异步复位信号（低电平有效）
    input ps2_clk,      // PS2接口时钟信号
    input ps2_data,     // PS2接口数据信号
    input nextdata_n,   // 数据读取请求信号（低电平有效）
    output [7:0] data,  // 当前读取的键盘数据
    output reg ready,   // FIFO数据就绪标志
    output reg overflow // FIFO溢出标志
);
    
    // internal signal, for test
    reg [9:0] buffer;        // ps2_data bits
    reg [7:0] fifo[7:0];     // data fifo
    reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
    reg [3:0] count;  // count ps2_data bits

    // detect falling edge of ps2_clk
    reg [2:0] ps2_clk_sync;

    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (clrn == 0) begin // reset
            count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
        end
        else begin
            if ( ready ) begin // read to output next data
                if(nextdata_n == 1'b0) //read next data
                begin
                    // $display("rptr: %d, w_ptr: %d, data: %h", r_ptr, w_ptr, data);
                    r_ptr <= r_ptr + 3'b1;
                    if(w_ptr==(r_ptr+3'b1)) //empty
                        ready <= 1'b0;
                end
            end
            if (sampling) begin
              if (count == 4'd10) begin
                if ((buffer[0] == 0) &&  // start bit
                    (ps2_data)       &&  // stop bit
                    (^buffer[9:1])) begin      // odd  parity
                    fifo[w_ptr] <= buffer[8:1];  // kbd scan code
                    w_ptr <= w_ptr+3'b1;
                    ready <= 1'b1;
                    overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
                end
                count <= 0;     // for next
              end else begin
                buffer[count] <= ps2_data;  // store ps2_data
                count <= count + 3'b1;
              end
            end
        end
    end
    assign data = fifo[r_ptr]; //always set output data

endmodule


module keyboard(
    input clk,
    input clrn,
    input ps2_clk,      // PS2接口时钟信号
    input ps2_data,     // PS2接口数据信号
    output reg [7:0] data,  // 当前读取的键盘数据
    output reg ready,   // FIFO数据就绪标志
    output reg overflow,// FIFO溢出标志
    output reg [7:0] ascii, // 输出ASCLL码
    output reg [7:0] count,  // 按键计数
    output reg off
);

    reg [7:0] ascii_table [0:255] = '{default: 8'h00};
    reg nextdata;
    reg fready;
    reg [7:0] keydata;

    initial begin
        ascii_table[8'h1C] = 8'h41; // A
        ascii_table[8'h32] = 8'h42; // B
        ascii_table[8'h21] = 8'h43; // C
        ascii_table[8'h23] = 8'h44; // D
        ascii_table[8'h24] = 8'h45; // E
        ascii_table[8'h2B] = 8'h46; // F
        ascii_table[8'h34] = 8'h47; // G
        ascii_table[8'h33] = 8'h48; // H
        ascii_table[8'h43] = 8'h49; // I
        ascii_table[8'h3B] = 8'h4A; // J
        ascii_table[8'h42] = 8'h4B; // K
        ascii_table[8'h4B] = 8'h4C; // L
        ascii_table[8'h3A] = 8'h4D; // M
        ascii_table[8'h31] = 8'h4E; // N
        ascii_table[8'h44] = 8'h4F; // O
        ascii_table[8'h4D] = 8'h50; // P
        ascii_table[8'h15] = 8'h51; // Q
        ascii_table[8'h2D] = 8'h52; // R
        ascii_table[8'h1B] = 8'h53; // S
        ascii_table[8'h2C] = 8'h54; // T
        ascii_table[8'h3C] = 8'h55; // U
        ascii_table[8'h2A] = 8'h56; // V
        ascii_table[8'h1D] = 8'h57; // W
        ascii_table[8'h22] = 8'h58; // X
        ascii_table[8'h35] = 8'h59; // Y
        ascii_table[8'h1A] = 8'h5A; // Z
        ascii_table[8'h16] = 8'h31; // 1
        ascii_table[8'h1E] = 8'h32; // 2
        ascii_table[8'h26] = 8'h33; // 3
        ascii_table[8'h25] = 8'h34; // 4
        ascii_table[8'h2E] = 8'h35; // 5
        ascii_table[8'h36] = 8'h36; // 6
        ascii_table[8'h3D] = 8'h37; // 7
        ascii_table[8'h3E] = 8'h38; // 8
        ascii_table[8'h46] = 8'h39; // 9
    end

    assign ascii = ascii_table[data];

    // 数据读取
    always @(posedge clk) begin
        fready <= ready;
        if (~fready & ready) begin
            data <= keydata;
            if (keydata == 8'hf0) begin
                count <= count + 1;
            end
            nextdata <= 1'b0;
        end
        else begin
            nextdata <= 1'b1;
        end
    end

    reg [15:0] counter;  // 计数器

    // 计数器逻辑
    always @(posedge clk) begin
        if (ready) begin
            counter <= 16'd0;
        end else begin
            if (counter < 16'hFFFF) begin
                counter <= counter + 1;
            end
        end

        // 一段时间内 ready 信号为低电平，判断为无输入
        if (counter > 16'h8888) begin
            off <= 1'b1;
        end else begin
            off <= 1'b0;
        end
    end

    ps2_keyboard u_ps2_keyboard(
        .clk        	(clk         ),
        .clrn       	(clrn        ),
        .ps2_clk    	(ps2_clk     ),
        .ps2_data   	(ps2_data    ),
        .nextdata_n 	(nextdata    ),
        .data       	(keydata     ),
        .ready      	(ready       ),
        .overflow   	(overflow    )
    );

endmodule
