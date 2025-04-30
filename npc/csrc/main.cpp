#include "tpdef.h"

void sdb_mainloop();

int main(int argc, char** argv)
{
    initialize(argc, argv);

    sdb_mainloop();

    return 0;
}