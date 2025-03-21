// 8-3 优先编码器电路
module encode83 (
    input [7:0] src,
    input en,
    output reg [2:0] ret,
    output isin
);

    integer i;
    always @(src or en) begin
        if (en) begin
            ret = 3'b000;
            for( i = 0; i < 8; i = i + 1)
                if(src[i] == 1) ret = i[2:0];
        end
        else  ret = 0;
    end

    assign isin = ~en && src == 0 ? 0 : 1;

endmodule


// 数码管显示模块
module segdis(
    input [2:0] num,
    output reg [7:0] led
);

    always @(num) begin
        case (num)
            0 : led = 8'b00000010;
            1 : led = 8'b10011110;
            2 : led = 8'b00100100;
            3 : led = 8'b00001100;
            4 : led = 8'b10011000;
            5 : led = 8'b01001000;
            6 : led = 8'b01000000;
            7 : led = 8'b00011110;
            default: led = 8'b11111111;
        endcase
    end

endmodule


module encode (
    input [7:0] src,
    input en,
    output isin,
    output reg [7:0] led,
    output reg [2:0] ret
);
    
    encode83 u_encode83(
        .src  	(src   ),
        .en   	(en    ),
        .ret  	(ret   ),
        .isin 	(isin  )
    );
    
    segdis u_segdis(
        .num 	(ret  ),
        .led 	(led  )
    );
    
endmodule
