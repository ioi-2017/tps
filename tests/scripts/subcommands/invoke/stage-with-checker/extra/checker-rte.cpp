#include "testlib.h"

int main(int argc, char* argv[]) {
	registerChecker("add1", argc, argv);
	int a = inf.readInt();
	if (a > 10) {
		TestlibFinalizeGuard::alive = false;
		exit(20);
	}
	int correctSum = ans.readInt();
	int output = ouf.readInt();
	ouf.skipBlanks();
	ouf.readEof();
	quitif(output != correctSum, _wa, "Wrong sum");
	quit(_ok);
}
