#include "testlib.h"

int main(int argc, char* argv[]) {
	registerChecker("add1", argc, argv);
	int correctSum = ans.readInt();
	int output = ouf.readInt();
	ouf.skipBlanks();
	ouf.readEof();
	quitif(output != correctSum, _wa, "Wrong sum");
	quit(_ok);
}
