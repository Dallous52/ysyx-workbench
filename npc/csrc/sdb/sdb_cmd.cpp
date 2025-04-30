#include "npc.h"
#include "tpdef.h"

#include <cstdio>
#include <iostream>
#include <cstring>

// continue
int cmd_c(char *args) 
{
  cpu_exec(-1);
  return 0;
}


// quit
int cmd_q(char *args) 
{
  finalize();
  return -1;
}


// Single step execution
int cmd_si(char* args)
{
  if (args == NULL)
    cpu_exec(1);
  else
  {
    int si_num = 0;
    if (sscanf(args, "%d", &si_num) == 1)
      cpu_exec((uint64_t)si_num);
    else
      printf("Please use \"si [N]\" to execute, N > 0.\n");
  }

  return 0;
}


// print infomation
int cmd_info(char* args)
{
    // void print_wp();

    bool exey = true;
    if (args == NULL || strlen(args) != 1)
    {
      exey = false;
      goto info_end;
    }
  
    if (*args == 'r')
      reg_print();
    else if (*args == 'w')
      printf("print watch point\n");
    else
      exey = false;
  
info_end:
    if (!exey) 
    {
      printf("Please use command: \"info r\" or \"info w\".\n");
    }
    
    return 0;
}


int cmd_x(char* args){return 0;}


int cmd_p(char* args)
{
    word_t expr(char* e, bool* success);

    bool success = false;
    word_t ret = expr(args, &success);
    if (success)
      printf("answer: 0x%x\n", ret);
    else
      printf("your expression have some error.\n");
  
    return 0;
}


int cmd_w(char* args){return 0;}
int cmd_d(char* args){return 0;}