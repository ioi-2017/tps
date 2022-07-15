#include "testlib.h"
using namespace std;

const int MAX_NUM = 1000;

int main() {
	registerValidation();
	inf.readInt(0, MAX_NUM, "a");
	inf.readSpace();
	inf.readInt(0, MAX_NUM, "b");
	inf.readEoln();
	inf.readEof();
	return 0;
}
