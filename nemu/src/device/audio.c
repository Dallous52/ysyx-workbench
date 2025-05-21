/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>
#include <device/map.h>
#include <SDL2/SDL.h>

enum {
  reg_freq,
  reg_channels,
  reg_samples,
  reg_sbuf_size,
  reg_init,
  reg_count,
  nr_reg
};

static uint8_t *sbuf = NULL;
static uint32_t *audio_base = NULL;

// 音频回调函数
void audio_callback(void *userdata, Uint8 *stream, int len) 
{
  uint32_t audio_len = audio_base[reg_sbuf_size];
  static uint32_t audio_pos = 0;

  printf("len: %d, pos %d, count %d\n", len, audio_pos, audio_base[reg_count]);
  if (audio_pos >= audio_len) {
    // 没有数据了，填充静音
    if (audio_base[reg_sbuf_size] != CONFIG_SB_SIZE)
      audio_base[reg_sbuf_size] = 0;
    
    SDL_memset(stream, 0, len);
    return;
  }

  Uint32 remaining = audio_len - audio_pos;
  Uint32 copy_len = (len > remaining) ? remaining : len;
  audio_base[reg_count] = remaining;

  SDL_memcpy(stream, sbuf + audio_pos, copy_len);
  audio_pos += copy_len;

  if (copy_len < len) {
    SDL_memset(stream + copy_len, 0, len - copy_len);
  }
}


static void audio_io_handler(uint32_t offset, int len, bool is_write) 
{
  if (audio_base[reg_init])
  {
    SDL_AudioSpec s = {};
    s.format = AUDIO_S16SYS;  // 假设系统中音频数据的格式总是使用16位有符号数来表示
    s.userdata = NULL;        // 不使用
  
    s.freq = audio_base[reg_freq];
    s.channels = audio_base[reg_channels];
    s.samples = audio_base[reg_samples];
    s.callback = audio_callback;
  
    SDL_InitSubSystem(SDL_INIT_AUDIO);
    SDL_OpenAudio(&s, NULL);
    SDL_PauseAudio(0);
    audio_base[reg_count] = CONFIG_SB_SIZE;
  }
}

void init_audio() 
{
  uint32_t space_size = sizeof(uint32_t) * nr_reg;
  audio_base = (uint32_t *)new_space(space_size);
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size, audio_io_handler);
#else
  add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size, audio_io_handler);
#endif

  sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
  add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
}
