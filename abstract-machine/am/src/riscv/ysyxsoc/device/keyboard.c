#include <am.h>
#include <klib.h>
#include <stdbool.h>

#include "amdev.h"
#include "device.h"
#include "../../riscv.h"


static int base_code[256] = {
    [0x1C] = 0x41, // A
    [0x32] = 0x42, // B
    [0x21] = 0x43, // C
    [0x23] = 0x44, // D
    [0x24] = 0x45, // E
    [0x2B] = 0x46, // F
    [0x34] = 0x47, // G
    [0x33] = 0x48, // H
    [0x43] = 0x49, // I
    [0x3B] = 0x4A, // J
    [0x42] = 0x4B, // K
    [0x4B] = 0x4C, // L
    [0x3A] = 0x4D, // M
    [0x31] = 0x4E, // N
    [0x44] = 0x4F, // O
    [0x4D] = 0x50, // P
    [0x15] = 0x51, // Q
    [0x2D] = 0x52, // R
    [0x1B] = 0x53, // S
    [0x2C] = 0x54, // T
    [0x3C] = 0x55, // U
    [0x2A] = 0x56, // V
    [0x1D] = 0x57, // W
    [0x22] = 0x58, // X
    [0x35] = 0x59, // Y
    [0x1A] = 0x5A, // Z
    [0x45] = 0x30, // 0
    [0x16] = 0x31, // 1
    [0x1E] = 0x32, // 2
    [0x26] = 0x33, // 3
    [0x25] = 0x34, // 4
    [0x2E] = 0x35, // 5
    [0x36] = 0x36, // 6
    [0x3D] = 0x37, // 7
    [0x3E] = 0x38, // 8
    [0x46] = 0x39  // 9
};


void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) 
{
  bool down;
  int code;
  while (1)
  {
    uint8_t ps2code = inb(DEV_KEYBOARD);
    if (ps2code == 0)
    {
      down = false; code = 0;
      break; 
    }
    else if (ps2code == 0xF0)
    {
      down = false;
    }
    else if (ps2code == 0xE0) 
    {
      ps2code = inb(DEV_KEYBOARD);
      code = AM_KEY_NONE; // ignore ext code
      break;
    }
    else
    {
      code = base_code[ps2code];
      break;
    }
  }

  kbd->keydown = down;
  kbd->keycode = code;
  if (code != 0)
  printf("code: %c\n", code);
}
