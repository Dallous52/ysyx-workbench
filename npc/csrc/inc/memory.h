#ifndef NPC_MEMORY
#define NPC_MEMORY

#include "tpdef.h"

#define PMEM_LEFT  ((paddr_t)MBASE)
#define PMEM_RIGHT ((paddr_t)MBASE + MSIZE - 1)

// 编译器内建函数，作用是告诉编译器某个条件的执行可能性，从而让编译器做优化
// __builtin_expect(expression, expected_value)
// expression：     一个表达式，比如一个条件判断。
// expected_value： 你预测 expression 最有可能的值（通常是 0 或 1）。
#define likely(cond)   __builtin_expect(cond, 1)

// 内存大小
#define MSIZE 0x8000000

// 内存起始地址
#define MBASE 0x80000000

typedef uint32_t paddr_t;

// 内存初始化
bool pmem_init(const char* fbin);

// 内存读操作
uint32_t paddr_read(uint32_t addr, int len);

// 内存写操作
void paddr_write(paddr_t addr, int len, word_t data);

#endif // NPC_MEMORY