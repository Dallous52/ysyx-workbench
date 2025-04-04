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

#include "common.h"
#include "isa.h"
#include "memory/paddr.h"

#include <ctype.h>
#include <stdio.h>

// max expression length
#define MAX_EXPR_LEN 65535

// expression core function (recursive processing)
static word_t expr_core(char* e, int p, int q);

// Ignore characters
static const char ignore[] = {
  ' ', '\t'
};
static int ignore_len = ARRLEN(ignore);


// operator characters
typedef struct operator{
  char op;
  char priority;
}oprt;


#define OPRTS_LEN 100
#define OPRT_MAX_PRIORITY 3
static oprt oprts[OPRTS_LEN] = { 0 };
static int oprt_hash = -1;

static int debugfunc(char* e) {
  e[0] = 0;
  return 0;
}

static void debuglook(const char* e, int p, int q)
{
  for (; p <= q; p++)
  {
    putc(e[p], stdout);
  }
  putc('\n', stdout);
}


void init_regex()
{
  static const oprt op[] = {
    {'*', 1}, {'/', 1},
    {'+', 2}, {'-', 2}, 
    {'!', 3}, {'=',3}, 
    {'&', 4}
  };

  static int oplen = ARRLEN(op);
  
  int i = 1; oprt_hash = op[0].op;
  for (; i < oplen; i++)
    oprt_hash = oprt_hash > op[i].op ? op[i].op : oprt_hash;

  for (i = 0; i < oplen; i++)
    oprts[op[i].op - oprt_hash] = op[i];
}


// ignore char return true
static bool is_ignore(char c)
{
  int i = ignore_len;

  while (i)
  {
    if (c == ignore[i - 1])
      return true;
    --i;
  }

  return false;
}


// get main operator
static int get_main_oprt(char* e, int p, int q)
{
  int ret = -1;
  
  char prio = 0;
  int bracket = 0;

  int i = p;
  for (; i <= q; i++)
  {
    // Skip parentheses 
    if (bracket || e[i] == '(')
    {
      if (e[i] == ')') bracket--;
      else if (e[i] == '(') bracket++;
      continue;
    }

    // judge operator
    short hash = e[i] - oprt_hash;
    if (hash < 0 || hash > OPRTS_LEN) continue;

    if (oprts[hash].op != 0 && 
        oprts[hash].priority >= prio)
    {
      // special operator
      if (i > p && oprts[e[i - 1] - oprt_hash].op != 0)
        continue;
      
      ret = i;
      prio = oprts[hash].priority;
    }
  }

  return ret;
}


// prase number
word_t prase_num(char* e, int p, int q)
{
  // copy num str
  int snum_len = q - p + 1;
  char* snum = DNEWS(char, snum_len + 1);
  strncpy(snum, e + p, snum_len);

  // prase
  int ret = 0;
  if (snum[0] == '0' && (snum[1] == 'x' || snum[1] == 'X'))
  {
    if (sscanf(snum, "%x", &ret) != 1)
    {
      DFREE(snum);
      return debugfunc(e);
    }
  }
  else if (sscanf(snum, "%d", &ret) != 1)
  {
    DFREE(snum);
    return debugfunc(e);
  }

  return ret;
}


// prase register
word_t prase_reg(char* e, int p, int q)
{
  // copy reg str
  int reg_len = q - p + 1;
  char* sreg = DNEWS(char, reg_len + 1);
  strncpy(sreg, e + p, reg_len);

  // prase
  bool success = false;
  word_t ret = isa_reg_str2val(sreg, &success);
  if (!success)
  {
    printf("register name maybe error.\n");
    debugfunc(e);
  }

  DFREE(sreg);
  return ret;
}


// dereference 
word_t dereference(char* e, int p, int q)
{
  paddr_t x_addr = expr_core(e, p, q);
  if (!e[0]) return 0;

  if (likely(in_pmem(x_addr)))
  {
    return paddr_read(x_addr, 4);
  }

  printf("Memory access out of bounds.\n");
  return 0;
}


// expression core function (recursive processing)
static word_t expr_core(char* e, int p, int q)
{
  if (e == NULL || e[0] == 0) return 0;
  debuglook(e, p, q);

  int mop = get_main_oprt(e, p, q);
  
  if (mop < 0)
  { 
    // if is number
    if (isdigit(e[p]))
      return prase_num(e, p, q);
    else if (e[p] == '$') // if is register
      return prase_reg(e, p + 1, q);
    else if (e[p] == '(') // if is ()
      return expr_core(e, p + 1, q - 1);
    else  // error
      return debugfunc(e);
  }
  else if (mop == p)
  {
    if (e[p] == '*')
      return dereference(e, p + 1, q);
    if (e[p] == '-')
      return -expr_core(e, p + 1, q);
  }
  else if (mop > p)
  {
    word_t va = expr_core(e, p, mop - 1);
    if (!e[0]) 
      return 0;

    int back = (oprts[e[mop] - oprt_hash].priority > 2) + 1;
    
    word_t vb = expr_core(e, mop + back, q);
    if (!e[0]) 
      return 0;

    switch (e[mop]) 
    {
      case '+': return va + vb;
      case '-': return va - vb;
      case '*': return va * vb;
      case '/': 
        if (vb) return va / vb;
        else return debugfunc(e);
      case '!': return va != vb;
      case '=': return va == vb;
      case '&': return va && vb;
      default: return debugfunc(e);
    }
  }

  return debugfunc(e);
}


// Expression
word_t expr(char *e, bool *success) 
{
  if (e == NULL || success == NULL) 
  {
    if (success == NULL)
      return 0;

    *success = false;
    return 0;
  }

  // expr len judge
  int elen = strlen(e);
  if (elen > MAX_EXPR_LEN)
  {
    *success = false;
    return 0;
  }

  // delete all 'space'
  char* etmp = DNEWS(char, elen + 1);
  int i = 0, j = 0;
  for (; i < elen; i++)
  {
    if (!is_ignore(e[i]))
    {
      etmp[j++] = e[i];
    }
  }
  etmp[j] = '\0';
  // printf("%s\n", etmp);

  // get resault
  word_t ret = expr_core(etmp, 0, j - 1);
  if (etmp[0] == 0) *success = false;
  else *success = true;

  DFREE(etmp);
  return ret;
}
