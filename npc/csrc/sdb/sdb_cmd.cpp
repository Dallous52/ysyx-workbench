#include "npc.h"
#include "tpdef.h"

#include <iostream> 

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


int cmd_info(char* args){return 0;}
int cmd_x(char* args){return 0;}
int cmd_p(char* args){return 0;}
int cmd_w(char* args){return 0;}
int cmd_d(char* args){return 0;}