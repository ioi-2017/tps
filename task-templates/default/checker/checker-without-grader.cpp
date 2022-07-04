#include "testlib.h"
using namespace std;

int main(int argc, char* argv[]) {
	registerChecker("__TPARAM_SHORT_NAME__", argc, argv);
	compareRemainingLines();
}
