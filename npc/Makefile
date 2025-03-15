all:
	@echo "Please use make sim."

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator --cc --exe --build -j 7 -Wall csrc/main.cpp vsrc/top.v
	make -C obj_dir -f Vtop.mk Vtop
	
run: sim
	./obj_dir/Vtop

clean:
	@rm -rf obj_dir

include ../Makefile
