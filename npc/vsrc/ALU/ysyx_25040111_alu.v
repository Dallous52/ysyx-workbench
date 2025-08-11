`ifndef NPC_ALU
`define NPC_ALU 

module ysyx_25040111_alu (
    input  [31:0] var1,
    input  [31:0] var2,
    input  [2:0]  opt,
    input         snpc,    // 如果为 1，则 adder 用常数 4
    input         ext,     // 在逻辑类里作为 OR/AND 选择（保留原接口名）
    input         sign,    // 比较/算术移位时是否按有符号处理
    input         negate,  // 比较结果取反控制
    output reg [31:0] res
);

    // --- 轻量中间信号 ---
    wire [31:0] adder_b = snpc ? 32'd4 : var2;
    wire [31:0] res_add;
    wire        overflow, cout;

    // 保持原有 adder 接口（你可以把下面的实例替换为面积更小的 adder）
    ysyx_25040111_adder32 u_adder32 (
        .ina      (var1),
        .inb      (adder_b),
        .sub      (ext),    // 保留原子口（你原代码用 ext 作为 sub）
        .sout     (res_add),
        .overflow (overflow),
        .cout     (cout)
    );

    // 其它单功能单元（只在需要时组合）
    wire [31:0] res_and = var1 & var2;
    wire [31:0] res_or  = var1 | var2;
    wire [31:0] res_xor = var1 ^ var2;

    // 逻辑移位和算术移位（用明确的 $signed 表达式）
    wire [4:0]  shamt = var2[4:0];
    wire [31:0] res_sll = var1 << shamt;
    wire [31:0] res_srl = var1 >> shamt;
    // 算术右移仅在 sign=1 时生效
    wire [31:0] res_sra = $signed(var1) >>> shamt;
    wire [31:0] res_shift = sign ? res_sra : res_srl;

    // 比较与相等：
    // lt: 保持原来基于 adder 的计算（你原来用 res_add/overflow/ cout）
    wire lt = sign ? (res_add[31] ^ overflow) : (~cout);
    wire eq = (var1 == var2);

    // 逐个结果形成（注意只有最后一步才扩展单比特值）
    wire [31:0] alu_pass = var1;
    wire [31:0] alu_add  = res_add;
    wire [31:0] alu_logic = ext ? res_or : res_and; // ext 用于 OR/AND 选择
    wire [31:0] alu_xor = res_xor;
    wire [31:0] alu_sll = res_sll;
    wire [31:0] alu_srl_sra = res_shift;
    wire [31:0] alu_lt = {31'b0, lt ^ negate};
    wire [31:0] alu_eq = {31'b0, (eq ^ negate)};

    // 使用二进制 ?: 树来选择结果（通常比大 case 生成更小的多路复用树）
    always @(*) begin
        res = (opt == 3'b000) ? alu_pass :
              (opt == 3'b001) ? alu_add :
              (opt == 3'b010) ? alu_logic :
              (opt == 3'b011) ? alu_xor :
              (opt == 3'b100) ? alu_sll :
              (opt == 3'b101) ? alu_srl_sra :
              (opt == 3'b110) ? alu_lt :
              (opt == 3'b111) ? alu_eq :
              32'b0;
    end

endmodule

`endif
