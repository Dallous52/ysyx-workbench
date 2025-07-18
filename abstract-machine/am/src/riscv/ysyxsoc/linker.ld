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
    KEEP(*(ssbl*))
    _ssbl_ed = .;
  } > sram AT> flash

  _code_start = _ssbl_load + (_ssbl_ed - _ssbl_op);
  .text : { /* 代码段 */
    _code_op = .;
    KEEP(*(.text._trm_init))
    *(.text*)
    _code_ed = .;
  } > psram AT> flash

  _rodata_start = _code_start + (_code_ed - _code_op);
  .rodata : { /* 只读全局变量 */
    _rodata_op = .;
    *(.rodata*)
    *(.srodata*)
    _rodata_ed = .;
  } > psram AT> flash

  _data_start = _rodata_start + (_rodata_ed - _rodata_op);
  .data : { /* 可读写全局变量 */
    _data_op = .;
    *(.data*)
    *(.data.*)
    *(.sdata.*)
    _data_ed = .;
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
