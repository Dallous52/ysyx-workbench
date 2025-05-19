#include <am.h>
#include <nemu.h>
#include <klib.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) 
{
  uint32_t keycode = inl(KBD_ADDR);
  if (keycode)printf("%08x\n", keycode);
  kbd->keydown = keycode == AM_KEY_NONE ? 0 : 1;
  kbd->keycode = keycode & ~KEYDOWN_MASK;
}
