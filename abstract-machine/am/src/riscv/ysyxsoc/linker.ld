ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

MEMORY {
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
  . = ORIGIN(mrom);
  .text : {
    *(entry) /* 把名为 entry 的自定义段放最前面 */
    *(.text*)
  } > mrom AT> mrom :text

  /* 只读全局变量 */
  .rodata : {
    *(.rodata*)
  } > mrom :text

  /* 可读写全局变量 */
  .data : AT(ADDR(.rodata) + SIZEOF(.rodata)) {
    _data_load_start = LOADADDR(.data);
    _data_start = .;
    *(.data)
    _data_end = .;
  } > sram :data

  .bss : {
    _bss_start = .;
    *(.bss*) *(.sbss*) *(.scommon)
    _bss_end = .;
  } > sram :data

  _heap_start = 0xF000800;
  _heap_end = 0xF001400;

  _stack_top = _heap_end;
  . = _stack_top + 0xC00;
  _stack_pointer = .;
}
