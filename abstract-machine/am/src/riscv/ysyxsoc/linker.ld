ENTRY(_fsbl)

MEMORY {
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
  psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
  . = ORIGIN(flash);

  .fsbl : {
    KEEP(*(entry))
  } > flash
  
  _ssbl_load = .;
  .ssbl : {
    _ssbl_op = .;
    KEEP(*(ssbl_top))
    KEEP(*(ssbl))
    _ssbl_ed = .;
  } > sram AT> flash

  _code_start = .;
  .text : { /* 代码段 */
    KEEP(*(code))
    KEEP(*(.text*))
  } > psram AT> flash

  .rodata : { /* 只读全局变量 */
    KEEP(*(.rodata*))
  } > psram AT> flash

  .data : { /* 可读写全局变量 */
    KEEP(*(.data))
    KEEP(*(.data.*))
    KEEP(*(.sdata.*))
  } > psram AT> flash
  _code_end = .;

  .bss : {
    KEEP(*(.bss*))
    KEEP(*(.sbss*))
    KEEP(*(.scommon))
  } > psram

  _heap_start = 0x80300000;
  _heap_end = 0x80400000;

  _stack_top = 0x0f000400;
  _stack_pointer = 0x0f002000;
}
