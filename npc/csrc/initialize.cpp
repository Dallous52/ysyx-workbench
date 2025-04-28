#include "memory.h"
#include <getopt.h>
#include <iostream>

static const char* binfile = NULL;

// 命令行参数解析
static int parse_args(int argc, char *argv[])
{
  const struct option table[] = {
    {"bin"    , no_argument      , NULL, 'b'},
    {0          , 0              , NULL,  0 }
  };

  int o;
  while ( (o = getopt_long(argc, argv, "-b:", table, NULL)) != -1) 
  {
    switch (o) 
    {
      case 'b': binfile = optarg; break;
      default:
        printf("Usage: \n");
        printf("\t-b,--bin              set binary file.\n");
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

  return true;
}
