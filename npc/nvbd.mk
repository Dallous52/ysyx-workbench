# Verilator 编译选项：
# - `-MMD`  : 生成 `.d` 依赖文件，支持增量编译
# - `--build` : 生成可执行文件
# - `-cc` : 生成 C++ 代码
# - `-O3` : 最高级别优化
# - `--x-assign fast` : 允许 `X` 值快速赋值，提高仿真效率
# - `--x-initial fast` : 允许 `X` 初值优化
# - `--noassert` : 关闭 Verilator 内部的 `assert`
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

nvbd:
	@echo "hello hello"