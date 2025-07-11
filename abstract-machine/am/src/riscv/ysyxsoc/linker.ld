ENTRY(_start)

MEMORY {
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
  . = ORIGIN(mrom);
  .text : {
    *(entry) /* 把名为 entry 的自定义段放最前面 */
    *(.text*)
  } > mrom AT> mrom

  /* 只读全局变量 */
  .rodata : {
    *(.rodata*)
  } > mrom

  /* 可读写全局变量 */
  _load_start = .;
  .data : {
    _data_start = .;
    *(.data)
    *(.data.*)
    _data_end = .;
  } > sram AT> mrom

  .bss : {
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sram

  _heap_start = 0xF000800;
  _heap_end = 0xF001400;

  _stack_top = _heap_end;
  . = _stack_top + 0xC00;
  _stack_pointer = .;
}
