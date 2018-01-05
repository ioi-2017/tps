#include "gencode.h"

int main(int argc, char *argv[])
{
  registerGen(argc, argv, 1);
  generate("no_limit", argc, argv);
  return 0;
}
