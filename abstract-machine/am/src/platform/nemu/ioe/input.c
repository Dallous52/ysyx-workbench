#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) 
{
  // uint32_t keycode = inl(KBD_ADDR);
  kbd->keydown = 0 == AM_KEY_NONE ? 0 : 1;
  kbd->keycode = (int)0;
}
