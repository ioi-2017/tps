#include "testlib.h"

int main(int argc, char *argv[])
{
  registerValidation();
  inf.readToken("no_limit", "subtask isn't no_limit");
  skip_ok();
}
