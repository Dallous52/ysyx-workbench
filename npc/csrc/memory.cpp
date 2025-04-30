#include "memory.h"

#include <cstddef>
#include <cstdio>
#include <cstring>
#include <fstream>


// 强制 4k 对齐
static uint8_t pmem[MSIZE] __attribute((aligned(4096))) = {};


// 内存越界判断
bool in_pmem(paddr_t addr) 
{
    return addr - MBASE < MSIZE;
}


// 真实内存读操作
static word_t host_read(void *addr, int len) 
{
    switch (len) {
      case 1: return *(uint8_t  *)addr;
      case 2: return *(uint16_t *)addr;
      case 4: return *(uint32_t *)addr;
      default: return 0;
    }
}
  

// 真实内存写操作
static void host_write(void *addr, int len, word_t data) 
{
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    default: return;
  }
}


// paddr - MBASE 计算真实偏移
// 定位 pmem 数组
static uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - MBASE; }


// 计算模拟内存地址 
static paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + MBASE; }


// 模拟内存读操作
static word_t pmem_read(paddr_t addr, int len)
{
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}


// 模拟内存写操作
static void pmem_write(paddr_t addr, int len, word_t data) 
{
  host_write(guest_to_host(addr), len, data);
}


// 越界判断
static void out_of_bound(paddr_t addr) 
{
  printf("address = %x is out of bound of pmem [%x, %x]",
      addr, PMEM_LEFT, PMEM_RIGHT);
}


// 加载二进制程序
static bool load_binary(const char* fbin)
{
  printf("[execute file] %s\n", fbin);

  std::ifstream file(fbin, std::ios::binary); 
  if (!file.is_open()) 
  {
      printf("open %s failed.\n", fbin);
      return false;
  }

  // 获取文件大小
  file.seekg(0, std::ios::end);
  std::streamsize fsize = file.tellg();
  file.seekg(0, std::ios::beg);

  if (fsize > MSIZE)
  {
      printf("binary file is too big\n");
      return false;
  }

  if (!file.read((char*)pmem, fsize))
  {
    printf("read %s failed\n", fbin);
    return false;
  }

  file.close();
  
  return true;
}


word_t paddr_read(paddr_t addr, int len)
{
  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  out_of_bound(addr);
  return 0;
}


void paddr_write(paddr_t addr, int len, word_t data)
{
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  out_of_bound(addr);
}


bool pmem_init(const char* fbin)
{
  static const uint32_t img [] = {
      0x00100093,  // addi x1, x0, 1
      0x00508113,  // addi x2, x1, 5
      0xFFF10193,  // addi x3, x2, -1
      0x06400513,  // addi x10, x0, 100
      0x00A28293,  // addi x5, x5, 10
      0x00000513,  // addi a0, x0, 0
      0x00100073   // ebreak    
  };
  
  if (fbin == NULL)
    memcpy(pmem, img, sizeof(img));
  else
    return load_binary(fbin);

  return true;
}


