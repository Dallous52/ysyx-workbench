AM_SRCS :=	riscv/ysyxsoc/start.S \
			riscv/ysyxsoc/trm.c \
           	riscv/ysyxsoc/device/device.c \
			riscv/ysyxsoc/device/uart.c \
			riscv/ysyxsoc/device/flash.c

CFLAGS    += -fdata-sections -ffunction-sections
LDSCRIPTS += $(AM_HOME)/am/src/riscv/ysyxsoc/linker.ld
LDFLAGS   += --gc-sections -e _start

MAINARGS_MAX_LEN = 64
MAINARGS_PLACEHOLDER = The insert-arg rule in Makefile will insert mainargs here.
CFLAGS += -DMAINARGS_MAX_LEN=$(MAINARGS_MAX_LEN) -DMAINARGS_PLACEHOLDER=\""$(MAINARGS_PLACEHOLDER)"\"

NPCFLAGS = -b$(IMAGE).bin -e$(IMAGE).elf -v

insert-arg: image
	@python3 $(AM_HOME)/tools/insert-arg.py $(IMAGE).bin $(MAINARGS_MAX_LEN) "$(MAINARGS_PLACEHOLDER)" "$(mainargs)"

image: image-dep
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: insert-arg
	@echo $(NPCFLAGS)
	$(MAKE) -C/home/dallous/Documents/ysyx-workbench/npc/ run ARGS="$(NPCFLAGS)"

.PHONY: insert-arg
