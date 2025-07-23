#include <am.h>
#include <klib.h>

#include "device.h"
#include "../../riscv.h"

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  // uint32_t keycode = inl(DEV_KEYBOARD);
  kbd->keydown = 0;
  kbd->keycode = AM_KEY_NONE;
}
