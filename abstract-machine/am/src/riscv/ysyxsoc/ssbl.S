.section ssbl, "ax"
.globl _ssbl
.type _ssbl, @function

_ssbl:
  mv s0, zero
  la sp, _stack_pointer
  call _second_bootloader
