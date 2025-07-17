ENTRY(_start)

MEMORY {
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  sram  : ORIGIN = 0x0f000000, LENGTH = 8K
  psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
  . = ORIGIN(flash);
  .text : {
    *(entry) /* 把名为 entry 的自定义段放最前面 */
    *(.text*)
  } > flash AT> flash

  /* 只读全局变量 */
  .rodata : {
    *(.rodata*)
  } > flash

  /* 可读写全局变量 */
  _load_start = .;
  .data : {
    _data_start = .;
    *(.data)
    *(.data.*)
    *(.sdata.*)
    _data_end = .;
  } > psram AT> flash

  .bss : {
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > psram

  _heap_start = 0x80100000;
  _heap_end = 0x80400000;

  _stack_top = 0x0f000000;
  . = _stack_top + 0x2000;
  _stack_pointer = .;
}
