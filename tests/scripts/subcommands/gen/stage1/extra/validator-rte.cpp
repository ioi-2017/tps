#include "testlib.h"
using namespace std;

const int MAX_NUM = 1000000;

int main() {
	registerValidation();
	int a = inf.readInt(0, MAX_NUM, "a");
	inf.readSpace();
	int b = inf.readInt(0, MAX_NUM, "b");
	inf.readEoln();
	inf.readEof();
	if (a > 10)
		exit(20);
	return 0;
}
