#include "memory.h"
#include "npc.h"

#include <getopt.h>
#include <iostream>


static const char* binfile = NULL;
static bool use_vcd = false;


// 命令行参数解析
static int parse_args(int argc, char *argv[])
{
  const struct option table[] = {
    {"bin"    , required_argument, NULL, 'b'},
    {"vcd"    , no_argument      , NULL, 'v'},
    {0        , 0                , NULL,  0 }
  };

  int o;
  while ( (o = getopt_long(argc, argv, "-b:v", table, NULL)) != -1) 
  {
    switch (o) 
    {
      case 'b': binfile = optarg; break;
      case 'v': use_vcd = true; break;
      default:
        printf("Usage: \n");
        printf("\t-b,--bin              Set binary file.\n");
        printf("\t-v,--vcd              Generate VCD waveform files.\n");
        printf("\n");
        exit(0);
    }
  }

  return 0;
}  


bool initialize(int argc, char** argv)
{
  parse_args(argc, argv);

  if (!pmem_init(binfile)) return false;

  npc_init(use_vcd);

  return true;
}


void finalize()
{
  npc_free();
  
  exit(0);
}