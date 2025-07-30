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

#include <isa.h>
#include <cpu/cpu.h>
#include <difftest-def.h>
#include <memory/paddr.h>
#include <stdio.h>

__EXPORT void difftest_memcpy(paddr_t addr, void *buf, size_t n, bool direction) 
{
  if (buf == NULL || n == 0 || !direction) return;

  uint8_t* wtbuf = (uint8_t*)buf;
  while (n)
  {
    if (n >= 4)
    {
      paddr_write(addr, 4, *((uint32_t*)wtbuf));
      n -= 4;
      wtbuf += 4;
      addr += 4;
    }
    else 
    {
      paddr_write(addr, 1, *wtbuf);
      n -= 1;
      wtbuf += 1;
      addr += 1;
    }
  }
}

__EXPORT void difftest_regcpy(void *dut, bool direction) 
{
  uint32_t* regs = (uint32_t*)dut;

  if (direction == DIFFTEST_TO_REF)
  {
    int i = 0;
    for (i = 0; i < 16; i++)
    {
      cpu.gpr[i] = regs[i];
    }  
  } 
  else 
  {
    int i = 0;
    for (i = 0; i < 16; i++)
    {
      regs[i] = cpu.gpr[i];
    }  
  }
}

__EXPORT void difftest_exec(uint64_t n) {
  printf("nume exec:pc0 %08x\n", cpu.pc);
  cpu_exec(n);
  printf("nume exec:pc1 %08x\n", cpu.pc);
}


__EXPORT void difftest_nop(void *dut, word_t dnpc) {
  // printf("nume nop:pc %08x\n", cpu.pc);
  uint32_t* regs = (uint32_t*)dut;
  int i = 0;
  for (i = 0; i < 16; i++)
  {
    cpu.gpr[i] = regs[i];
  }  
  cpu.pc = dnpc;
}


__EXPORT void difftest_raise_intr(word_t NO) {
  assert(0);
}

__EXPORT void difftest_init(int port, word_t pc) {
  void init_mem();
  init_mem();
  /* Perform ISA dependent initialization. */
  init_isa();
  cpu.pc = pc;
}
