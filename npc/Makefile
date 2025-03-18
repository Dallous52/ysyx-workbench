
all:
	@echo "Please use make sim."

# build project
sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator --cc --exe --build -j 4 -Wall --trace csrc/verilator.cpp vsrc/top.v
	make -C obj_dir -f Vtop.mk Vtop

# gtkwave
gtkwave:
	@if [ -f waveform.vcd ]; then \
		gtkwave waveform.vcd; \
	else \
		echo "\033[31mPlease include and use <verilated_vcd_c.h> to create waveform.vcd.\033[31m"; \
	fi

include nvbd.mk

# nvboard test
nvboard: nvbd
	./obj_dir/top


# build and run
run: sim
	./obj_dir/Vtop

clean:
	@rm -rf obj_dir
	@rm -f waveform.vcd

include ../Makefile
