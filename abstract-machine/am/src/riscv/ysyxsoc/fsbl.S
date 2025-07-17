.section entry, "ax"
.globl _fsbl
.type _fsbl, @function

_fsbl:
  mv s0, zero
  la sp, _stack_pointer
  call _first_bootloader
