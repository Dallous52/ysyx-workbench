# Verilator 编译选项：
# -MMD: 生成 .d 依赖文件，支持增量编译
# -build: 生成可执行文件
# -cc: 生成 C++ 代码
# -O3: 最高级别优化
# --x-assign fast: 允许 X 值快速赋值，提高仿真效率
# --x-initial fast: 允许 X 初值优化
# --noassert: 关闭 Verilator 内部的 assert
VERILATOR_CFLAGS += -MMD --build -cc  --autoflush \
				-O3 --x-assign fast --x-initial fast --noassert \
				--timescale "1ns/1ns" --no-timing

# 顶层模块名称
TOPNAME ?= ysyx_25040111 # ysyxSoCFull

# ysyxSoC 目录
SOC_DIR = /home/dallous/Documents/ysyx-workbench/ysyxSoC

ARGS ?= 

# 获取所有 Verilog 源文件（`vsrc` 目录下的 `.v` 文件）
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")

ifeq ($(TOPNAME), ysyxSoCFull)
VSRCS += $(shell find $(SOC_DIR)/perip -name "*.v")
VSRCS += $(SOC_DIR)/build/ysyxSoCFull.v
endif

CURRDIR ?= /home/dallous/Documents/ysyx-workbench/npc
RTL_FILE = $(VSRCS)


# 获取所有 C/C++ 源文件（`csrc` 目录下的 `.c`、`.cc`、`.cpp` 文件）
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")


# C++ 编译选项：
ifeq ($(TOPNAME), ysyxSoCFull)
INCFLAGS = $(addprefix -I, $(NVBOARD_HOME)/usr/include)
endif

INCFLAGS += -I/home/dallous/Documents/ysyx-workbench/npc/csrc/inc/
INCFLAGS += -I/home/dallous/Documents/ysyx-workbench/nemu/tools/capstone/repo/include/


# - `-DTOP_NAME="V$(TOPNAME)"` 定义宏 `TOP_NAME`，用于 Verilator 生成的顶层模块
CXXFLAGS += $(INCFLAGS) # -g
VERILATOR_CFLAGS +=	-Wno-UNOPTFLAT \
					-I/home/dallous/Documents/ysyx-workbench/npc/vsrc/ \
					-I/home/dallous/Documents/ysyx-workbench/npc/vsrc/IDU \

ifeq ($(TOPNAME), ysyxSoCFull)
VERILATOR_CFLAGS +=	-I$(SOC_DIR)/perip/uart16550/rtl \
					-I$(SOC_DIR)/perip/spi/rtl
endif


# LDFLAGS 添加链接库
LDFLAGS += -L/usr/lib/x86_64-linux-gnu -lreadline -lhistory

ifeq ($(TOPNAME), ysyxSoCFull)
include $(NVBOARD_HOME)/scripts/nvboard.mk
endif

all: sim

# simple sim test
sim: $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator $(VERILATOR_CFLAGS) \
		--trace --top-module ${TOPNAME} $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--exe -o top

sta:
	make -C/home/dallous/Documents/yosys-sta/ RTL_FILES="$(RTL_FILE)" \
		DESIGN=ysyx_25040111_top ANSWER_DIR=$(CURRDIR)/ sta

# gtkwave
gtkwave:
	@if [ -f waveform.vcd ]; then \
		gtkwave waveform.vcd; \
	else \
		echo "\033[31mPlease include and use <verilated_vcd_c.h> to create waveform.vcd\033[31m"; \
	fi

# build and run
run: sim
	./obj_dir/top $(ARGS)

pref:
	make -C/home/dallous/Documents/ysyx-workbench/am-kernels/benchmarks/microbench/ \
		ARCH=riscv32e-ysyxsoc run mainargs=test

clean:
	@rm -rf obj_dir
	@rm -f waveform.vcd
	@rm -rf result

include ../Makefile
