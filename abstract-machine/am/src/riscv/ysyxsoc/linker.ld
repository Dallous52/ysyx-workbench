ENTRY(_fsbl)

MEMORY {
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
  psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
  . = ORIGIN(flash);

  .fsbl : {
    *(entry)
  } > flash
  
  _ssbl_load = .;
  .ssbl : {
    _ssbl_op = .;
    KEEP(*(ssbl.boot))
    _ssbl_ed = .;
  } > sram AT> flash

  _code_start = _ssbl_load + (_ssbl_ed - _ssbl_op);
  .text : { /* 代码段 */
    _code_op = .;
    KEEP(*(.text._trm_init))
    *(.text*)
  } > psram AT> flash

  .rodata : { /* 只读全局变量 */
    *(.rodata*)
    *(.srodata*)
  } > psram AT> flash

  .data : { /* 可读写全局变量 */
    *(.data*)
    *(.data.*)
    *(.sdata.*)
    _code_ed = .;
  } > psram AT> flash

  .bss : {
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > psram

  _heap_start = 0x80300000;
  _heap_end = 0x80400000;

  _stack_top = 0x0f000400;
  _stack_pointer = 0x0f002000;
}
