/bin/echo -e "NAME = select-sort\nSRCS = tests/select-sort.c\ninclude ${AM_HOME}/Makefile" > Makefile.select-sort
if make -s -f Makefile.select-sort ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" select-sort >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" select-sort >> .result; \
fi
rm -f Makefile.select-sort
/bin/echo -e "NAME = unalign\nSRCS = tests/unalign.c\ninclude ${AM_HOME}/Makefile" > Makefile.unalign
if make -s -f Makefile.unalign ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" unalign >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" unalign >> .result; \
fi
rm -f Makefile.unalign
/bin/echo -e "NAME = shuixianhua\nSRCS = tests/shuixianhua.c\ninclude ${AM_HOME}/Makefile" > Makefile.shuixianhua
if make -s -f Makefile.shuixianhua ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" shuixianhua >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" shuixianhua >> .result; \
fi
rm -f Makefile.shuixianhua
/bin/echo -e "NAME = hello-str\nSRCS = tests/hello-str.c\ninclude ${AM_HOME}/Makefile" > Makefile.hello-str
if make -s -f Makefile.hello-str ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" hello-str >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" hello-str >> .result; \
fi
rm -f Makefile.hello-str
/bin/echo -e "NAME = movsx\nSRCS = tests/movsx.c\ninclude ${AM_HOME}/Makefile" > Makefile.movsx
if make -s -f Makefile.movsx ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" movsx >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" movsx >> .result; \
fi
rm -f Makefile.movsx
/bin/echo -e "NAME = crc32\nSRCS = tests/crc32.c\ninclude ${AM_HOME}/Makefile" > Makefile.crc32
if make -s -f Makefile.crc32 ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" crc32 >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" crc32 >> .result; \
fi
rm -f Makefile.crc32
/bin/echo -e "NAME = matrix-mul\nSRCS = tests/matrix-mul.c\ninclude ${AM_HOME}/Makefile" > Makefile.matrix-mul
if make -s -f Makefile.matrix-mul ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" matrix-mul >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" matrix-mul >> .result; \
fi
rm -f Makefile.matrix-mul
/bin/echo -e "NAME = mersenne\nSRCS = tests/mersenne.c\ninclude ${AM_HOME}/Makefile" > Makefile.mersenne
if make -s -f Makefile.mersenne ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" mersenne >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" mersenne >> .result; \
fi
rm -f Makefile.mersenne
/bin/echo -e "NAME = load-store\nSRCS = tests/load-store.c\ninclude ${AM_HOME}/Makefile" > Makefile.load-store
if make -s -f Makefile.load-store ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" load-store >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" load-store >> .result; \
fi
rm -f Makefile.load-store
/bin/echo -e "NAME = add\nSRCS = tests/add.c\ninclude ${AM_HOME}/Makefile" > Makefile.add
if make -s -f Makefile.add ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" add >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" add >> .result; \
fi
rm -f Makefile.add
/bin/echo -e "NAME = max\nSRCS = tests/max.c\ninclude ${AM_HOME}/Makefile" > Makefile.max
if make -s -f Makefile.max ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" max >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" max >> .result; \
fi
rm -f Makefile.max
/bin/echo -e "NAME = sub-longlong\nSRCS = tests/sub-longlong.c\ninclude ${AM_HOME}/Makefile" > Makefile.sub-longlong
if make -s -f Makefile.sub-longlong ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" sub-longlong >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" sub-longlong >> .result; \
fi
rm -f Makefile.sub-longlong
/bin/echo -e "NAME = dummy\nSRCS = tests/dummy.c\ninclude ${AM_HOME}/Makefile" > Makefile.dummy
if make -s -f Makefile.dummy ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" dummy >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" dummy >> .result; \
fi
rm -f Makefile.dummy
/bin/echo -e "NAME = wanshu\nSRCS = tests/wanshu.c\ninclude ${AM_HOME}/Makefile" > Makefile.wanshu
if make -s -f Makefile.wanshu ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" wanshu >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" wanshu >> .result; \
fi
rm -f Makefile.wanshu
/bin/echo -e "NAME = switch\nSRCS = tests/switch.c\ninclude ${AM_HOME}/Makefile" > Makefile.switch
if make -s -f Makefile.switch ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" switch >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" switch >> .result; \
fi
rm -f Makefile.switch
/bin/echo -e "NAME = min3\nSRCS = tests/min3.c\ninclude ${AM_HOME}/Makefile" > Makefile.min3
if make -s -f Makefile.min3 ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" min3 >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" min3 >> .result; \
fi
rm -f Makefile.min3
/bin/echo -e "NAME = string\nSRCS = tests/string.c\ninclude ${AM_HOME}/Makefile" > Makefile.string
if make -s -f Makefile.string ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" string >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" string >> .result; \
fi
rm -f Makefile.string
/bin/echo -e "NAME = fact\nSRCS = tests/fact.c\ninclude ${AM_HOME}/Makefile" > Makefile.fact
if make -s -f Makefile.fact ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" fact >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" fact >> .result; \
fi
rm -f Makefile.fact
/bin/echo -e "NAME = shift\nSRCS = tests/shift.c\ninclude ${AM_HOME}/Makefile" > Makefile.shift
if make -s -f Makefile.shift ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" shift >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" shift >> .result; \
fi
rm -f Makefile.shift
/bin/echo -e "NAME = goldbach\nSRCS = tests/goldbach.c\ninclude ${AM_HOME}/Makefile" > Makefile.goldbach
if make -s -f Makefile.goldbach ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" goldbach >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" goldbach >> .result; \
fi
rm -f Makefile.goldbach
/bin/echo -e "NAME = mov-c\nSRCS = tests/mov-c.c\ninclude ${AM_HOME}/Makefile" > Makefile.mov-c
if make -s -f Makefile.mov-c ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" mov-c >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" mov-c >> .result; \
fi
rm -f Makefile.mov-c
/bin/echo -e "NAME = quick-sort\nSRCS = tests/quick-sort.c\ninclude ${AM_HOME}/Makefile" > Makefile.quick-sort
if make -s -f Makefile.quick-sort ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" quick-sort >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" quick-sort >> .result; \
fi
rm -f Makefile.quick-sort
/bin/echo -e "NAME = if-else\nSRCS = tests/if-else.c\ninclude ${AM_HOME}/Makefile" > Makefile.if-else
if make -s -f Makefile.if-else ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" if-else >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" if-else >> .result; \
fi
rm -f Makefile.if-else
/bin/echo -e "NAME = bubble-sort\nSRCS = tests/bubble-sort.c\ninclude ${AM_HOME}/Makefile" > Makefile.bubble-sort
if make -s -f Makefile.bubble-sort ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" bubble-sort >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" bubble-sort >> .result; \
fi
rm -f Makefile.bubble-sort
/bin/echo -e "NAME = to-lower-case\nSRCS = tests/to-lower-case.c\ninclude ${AM_HOME}/Makefile" > Makefile.to-lower-case
if make -s -f Makefile.to-lower-case ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" to-lower-case >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" to-lower-case >> .result; \
fi
rm -f Makefile.to-lower-case
/bin/echo -e "NAME = recursion\nSRCS = tests/recursion.c\ninclude ${AM_HOME}/Makefile" > Makefile.recursion
if make -s -f Makefile.recursion ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" recursion >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" recursion >> .result; \
fi
rm -f Makefile.recursion
/bin/echo -e "NAME = fib\nSRCS = tests/fib.c\ninclude ${AM_HOME}/Makefile" > Makefile.fib
if make -s -f Makefile.fib ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" fib >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" fib >> .result; \
fi
rm -f Makefile.fib
/bin/echo -e "NAME = bit\nSRCS = tests/bit.c\ninclude ${AM_HOME}/Makefile" > Makefile.bit
if make -s -f Makefile.bit ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" bit >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" bit >> .result; \
fi
rm -f Makefile.bit
/bin/echo -e "NAME = pascal\nSRCS = tests/pascal.c\ninclude ${AM_HOME}/Makefile" > Makefile.pascal
if make -s -f Makefile.pascal ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" pascal >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" pascal >> .result; \
fi
rm -f Makefile.pascal
/bin/echo -e "NAME = div\nSRCS = tests/div.c\ninclude ${AM_HOME}/Makefile" > Makefile.div
if make -s -f Makefile.div ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" div >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" div >> .result; \
fi
rm -f Makefile.div
/bin/echo -e "NAME = mul-longlong\nSRCS = tests/mul-longlong.c\ninclude ${AM_HOME}/Makefile" > Makefile.mul-longlong
if make -s -f Makefile.mul-longlong ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" mul-longlong >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" mul-longlong >> .result; \
fi
rm -f Makefile.mul-longlong
/bin/echo -e "NAME = sum\nSRCS = tests/sum.c\ninclude ${AM_HOME}/Makefile" > Makefile.sum
if make -s -f Makefile.sum ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" sum >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" sum >> .result; \
fi
rm -f Makefile.sum
/bin/echo -e "NAME = leap-year\nSRCS = tests/leap-year.c\ninclude ${AM_HOME}/Makefile" > Makefile.leap-year
if make -s -f Makefile.leap-year ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" leap-year >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" leap-year >> .result; \
fi
rm -f Makefile.leap-year
/bin/echo -e "NAME = prime\nSRCS = tests/prime.c\ninclude ${AM_HOME}/Makefile" > Makefile.prime
if make -s -f Makefile.prime ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" prime >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" prime >> .result; \
fi
rm -f Makefile.prime
/bin/echo -e "NAME = add-longlong\nSRCS = tests/add-longlong.c\ninclude ${AM_HOME}/Makefile" > Makefile.add-longlong
if make -s -f Makefile.add-longlong ARCH= ; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" add-longlong >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" add-longlong >> .result; \
fi
rm -f Makefile.add-longlong
echo "test list [35 item(s)]:" select-sort unalign shuixianhua hello-str movsx crc32 matrix-mul mersenne load-store add max sub-longlong dummy wanshu switch min3 string fact shift goldbach mov-c quick-sort if-else bubble-sort to-lower-case recursion fib bit pascal div mul-longlong sum leap-year prime add-longlong
/bin/echo -e "NAME = add\nSRCS = tests/add.c\ninclude ${AM_HOME}/Makefile" > Makefile.add
if make -s -f Makefile.add ARCH=riscv32-nemu run; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" add >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" add >> .result; \
fi
rm -f Makefile.add
echo "test list [1 item(s)]:" add
cat .result
rm .result
Makefile:18: update target 'Makefile.add' due to: tests/add.c latest
/bin/echo -e "NAME = add\nSRCS = tests/add.c\ninclude ${AM_HOME}/Makefile" > Makefile.add
if make -s -f Makefile.add ARCH=riscv32-nemu run; then \
	printf "[%14s] \033[1;32mPASS\033[0m\n" add >> .result; \
else \
	printf "[%14s] \033[1;31m***FAIL***\033[0m\n" add >> .result; \
fi
# Building add-run [riscv32-nemu]
/home/dallous/Documents/ysyx-workbench/abstract-machine/Makefile:123: target 'am' does not exist
make -s -C /home/dallous/Documents/ysyx-workbench/abstract-machine/am archive
# Building am-archive [riscv32-nemu]
/home/dallous/Documents/ysyx-workbench/abstract-machine/Makefile:123: target 'klib' does not exist
make -s -C /home/dallous/Documents/ysyx-workbench/abstract-machine/klib archive
# Building klib-archive [riscv32-nemu]
/home/dallous/Documents/ysyx-workbench/abstract-machine/scripts/platform/nemu.mk:25: update target 'image' due to: image-dep
riscv64-linux-gnu-objdump -d /home/dallous/Documents/ysyx-workbench/am-kernels/tests/cpu-tests/build/add-riscv32-nemu.elf > /home/dallous/Documents/ysyx-workbench/am-kernels/tests/cpu-tests/build/add-riscv32-nemu.txt
echo + OBJCOPY "->" build/add-riscv32-nemu.bin
+ OBJCOPY -> build/add-riscv32-nemu.bin
riscv64-linux-gnu-objcopy -S --set-section-flags .bss=alloc,contents -O binary /home/dallous/Documents/ysyx-workbench/am-kernels/tests/cpu-tests/build/add-riscv32-nemu.elf /home/dallous/Documents/ysyx-workbench/am-kernels/tests/cpu-tests/build/add-riscv32-nemu.bin
/home/dallous/Documents/ysyx-workbench/abstract-machine/scripts/platform/nemu.mk:22: update target 'insert-arg' due to: image
python3 /home/dallous/Documents/ysyx-workbench/abstract-machine/tools/insert-arg.py /home/dallous/Documents/ysyx-workbench/am-kernels/tests/cpu-tests/build/add-riscv32-nemu.bin 64 "The insert-arg rule in Makefile will insert mainargs here." ""
mainargs=
/home/dallous/Documents/ysyx-workbench/abstract-machine/scripts/platform/nemu.mk:30: update target 'run' due to: insert-arg
make -C /home/dallous/Documents/ysyx-workbench/nemu ISA=riscv32 run ARGS="-l /home/dallous/Documents/ysyx-workbench/am-kernels/tests/cpu-tests/build/nemu-log.txt" CONFIG_TARGET_AM=1 IMG=/home/dallous/Documents/ysyx-workbench/am-kernels/tests/cpu-tests/build/add-riscv32-nemu.bin
# Building riscv32-nemu-interpreter-run [riscv32-nemu]
/home/dallous/Documents/ysyx-workbench/abstract-machine/Makefile:123: target '-ldl' does not exist
make -s -C /home/dallous/Documents/ysyx-workbench/abstract-machine/-ldl archive
rm -f Makefile.add
Makefile:13: update target 'all' due to: Makefile.add
echo "test list [1 item(s)]:" add
test list [1 item(s)]: add
Makefile:27: update target 'run' due to: all
cat .result
[           add] [1;31m***FAIL***[0m
rm .result
