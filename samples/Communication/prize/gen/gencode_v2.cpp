#include "gencode.h"

int main(int argc, char* argv[])
{
  registerGen(argc, argv, 1);
  generate("v2", argc, argv);
  return 0;
}
