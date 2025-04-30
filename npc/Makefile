# Verilator 编译选项：
# -MMD: 生成 .d 依赖文件，支持增量编译
# -build: 生成可执行文件
# -cc: 生成 C++ 代码
# -O3: 最高级别优化
# --x-assign fast: 允许 X 值快速赋值，提高仿真效率
# --x-initial fast: 允许 X 初值优化
# --noassert: 关闭 Verilator 内部的 assert
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert

# 顶层模块名称
TOPNAME = ysyx_25040111_top

# 模拟器名称
VSIM = VSIM_T

# 功能名称
FNAME ?= NONE_F

ARGS ?=

# 获取所有 Verilog 源文件（`vsrc` 目录下的 `.v` 文件）
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")

# 获取所有 C/C++ 源文件（`csrc` 目录下的 `.c`、`.cc`、`.cpp` 文件）
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")

# C++ 编译选项：
INCFLAGS = $(addprefix -I, $(NVBOARD_HOME)/usr/include)

# - `-DTOP_NAME="V$(TOPNAME)"` 定义宏 `TOP_NAME`，用于 Verilator 生成的顶层模块
CXXFLAGS += $(INCFLAGS) -I/home/dallous/Documents/ysyx-workbench/npc/csrc/inc/ -DTOP_NAME="\"V$(TOPNAME)\"" -D${FNAME} -lreadline -lhistory
VERILATOR_CFLAGS += -Wno-UNOPTFLAT -I/home/dallous/Documents/ysyx-workbench/npc/vsrc/

all: sim

# simple sim test
sim: $(VSRCS) $(CSRCS)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator $(VERILATOR_CFLAGS) \
		--trace --top-module ${TOPNAME} $^ \
		-CFLAGS -D$(VSIM) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--exe -o top

# gtkwave
gtkwave:
	@if [ -f waveform.vcd ]; then \
		gtkwave waveform.vcd; \
	else \
		echo "\033[31mPlease include and use <verilated_vcd_c.h> to create waveform.vcd\033[31m"; \
	fi


# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

# nvboard test
nvboard: $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@rm -rf ./obj_dir
	verilator $(VERILATOR_CFLAGS) \
		--top-module ${TOPNAME} $^ \
		-CFLAGS -D$(NVBD) \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--exe -o top

# build and run
run: sim
	./obj_dir/top $(ARGS)

clean:
	@rm -rf obj_dir
	@rm -f waveform.vcd

include ../Makefile
