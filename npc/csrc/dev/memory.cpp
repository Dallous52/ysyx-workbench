#include "memory.h"
#include "npc.h"
#include "tpdef.h"

#include <cstdio>
#include <cstring>
#include <fstream>


// virtual device
static uint8_t pmem[MSIZE] __attribute((aligned(4096))) = {};
static uint8_t pflash[512]  __attribute((aligned(4096))) = {};

// img size
static size_t imgsize = 0;

// is in pmem
bool in_pmem(paddr_t addr) 
{
    return addr - MBASE < MSIZE;
}


// read from real device
static word_t host_read(void *addr, int len) 
{
    switch (len) {
      case 1: return *(uint8_t  *)addr;
      case 2: return *(uint16_t *)addr;
      case 4: return *(uint32_t *)addr;
      default: return 0;
    }
}
  

// write in real device
static void host_write(void *addr, int len, word_t data) 
{
  switch (len) {
    case 1: *(uint8_t  *)addr = data; return;
    case 2: *(uint16_t *)addr = data; return;
    case 4: *(uint32_t *)addr = data; return;
    default: return;
  }
}


// get real address
uint8_t* guest_to_host(paddr_t paddr) { return pmem + (paddr - MBASE); }


// get virtual address
paddr_t host_to_guest(uint8_t *haddr) { return (haddr - pmem) + MBASE; }


static word_t pmem_read(paddr_t addr, int len)
{
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}


static void pmem_write(paddr_t addr, int len, word_t data) 
{
  host_write(guest_to_host(addr), len, data);
}


// error message
static void out_of_bound(paddr_t addr) 
{
  printf("address = %x is out of bound of pmem [%x, %x]\n",
      addr, PMEM_LEFT, PMEM_RIGHT);
  npc_stat = NPC_ABORT;
}


// load binary file to execute
static bool load_binary(const char* fbin, uint8_t* mem)
{
  printf(ANSI_FMT("[execute file] %s\n", ANSI_FG_BLUE), fbin);

  std::ifstream file(fbin, std::ios::binary); 
  if (!file.is_open()) 
  {
      printf("open %s failed.\n", fbin);
      return false;
  }

  // get file size
  file.seekg(0, std::ios::end);
  std::streamsize fsize = file.tellg();
  file.seekg(0, std::ios::beg);

  if (fsize > MSIZE)
  {
      printf("binary file is too big\n");
      return false;
  }

  if (!file.read((char*)mem, fsize))
  {
    printf("read %s failed\n", fbin);
    return false;
  }

  file.close();
  if (mem == pmem) imgsize = fsize;

  return true;
}


size_t get_img_size()
{
  return imgsize;
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
  
  imgsize = sizeof(img);
  if (fbin == NULL || !load_binary(fbin, pmem))
  {
    printf(ANSI_FMT("load img file failed.\n", ANSI_FG_RED));
  }
  // "/home/dallous/Documents/ysyx-workbench/am-kernels/kernels/hello/build/hello-riscv32e-ysyxsoc.bin"
  // load_binary(fbin, pflash);

  return true;
}


extern "C" void flash_read(int32_t addr, int32_t *data) 
{
  uint32_t address = (addr & ~0x3u) + MBASE;
  // printf(ANSI_FMT("load flash 0x%08x  ", ANSI_FG_GREEN), address);
  if (likely(in_pmem(address)))
  {
    *data = paddr_read(address, 4);
    // printf(ANSI_FMT("data 0x%08x.\n", ANSI_FG_GREEN), *data);
    return;
  }

	finalize(2);
}


extern "C" void mrom_read(int32_t addr, int32_t *data) 
{
	paddr_t address = addr & ~0x3u;

	if (likely(in_pmem(address)))
  {
    
    *data = paddr_read(address, 4);
    return;
  }

	finalize(2);
}


// extern "C" int pmem_read(int raddr) 
// {
// 	paddr_t address = raddr & ~0x3u;
// 	word_t rdata = 0;

// 	if (likely(in_pmem(address)))
// 		rdata = paddr_read(address, 4);
// 	else if (!device_call((paddr_t)raddr, &rdata, false))
// 		finalize(2);

// #if defined(EN_TRACE) && defined(MTRACE)
// 	// mtrace memory read
// 	word_t minst = paddr_read(CPU_PC, 4);
// 	if (raddr != CPU_PC && 0b0000011 == BITS(minst, 6, 0)) 
// 	{
// 		printf(ANSI_FMT("[read mem] address: 0x%08x; data: 0x%08x; pc: 0x%08x;\n",
// 						ANSI_FG_CYAN),
// 			(word_t)raddr, rdata, CPU_PC);
// 	}
// #endif // MTRACE

// 	// 总是读取地址为`raddr & ~0x3u`的4字节返回
// 	return (int)rdata;
// }


// static void pmem_write_core(paddr_t address, int wdata, char wmask) 
// {
// 	// 读出当前地址上的完整 4 字节
// 	word_t wdata_ = paddr_read(address, 4);

// 	// 使用掩码逐字节合成新的数据
// 	for (int i = 0; i < 4; ++i) 
// 	{
// 		if (wmask & (1 << i)) 
// 		{
// 			// 替换 old_data 中对应字节为 wdata 中对应的字节
// 			uint8_t byte = ((word_t)wdata >> (8 * i)) & 0xFF;
// 			wdata_ &= ~(0xFFu << (8 * i));       // 清空对应位置
// 			wdata_ |= ((word_t)byte << (8 * i)); // 写入对应字节
// 		}
// 	}

// 	// 按4字节对齐写入
// 	paddr_write(address, 4, wdata_);
// }


// extern "C" void pmem_write(int waddr, int wdata, char wmask) 
// {
// 	// 总是往地址为`waddr & ~0x3u`的4字节按写掩码`wmask`写入`wdata`
// 	// `wmask`中每比特表示`wdata`中1个字节的掩码
// 	// 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变

// 	paddr_t address = waddr & ~0x3u;

// #if defined(EN_TRACE) && defined(MTRACE)
// 	// mtrace memory write
// 	word_t minst = paddr_read(CPU_PC, 4);
// 	if (0b0100011 == BITS(minst, 6, 0)) 
// 	{
// 		printf(ANSI_FMT("[write mem] address: 0x%08x; data: 0x%08x; pc: 0x%08x; "
// 						"mask: 0x%02x;\n",
// 						ANSI_FG_CYAN),
// 			(paddr_t)waddr, (word_t)wdata, CPU_PC, wmask);
// 	}
// #endif // MTRACE

// 	if (likely(in_pmem(address))) 
// 	{
// 		pmem_write_core(address, wdata, wmask);
// 		return;
// 	}
// 	if (device_call((paddr_t)waddr, &wdata, true))
// 		return;

// 	finalize(2);
// }
