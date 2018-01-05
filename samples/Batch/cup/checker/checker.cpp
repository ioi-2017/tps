#include "testlib.h"
#include <iostream>
#include <fstream>
#include <iomanip>
#include <cstdlib>
using namespace std;

const string output_secret = "be6fe19e-6ee7-4837-a81e-6f6902743b31";

NORETURN void qp(int grade) {
  quitp(grade/double(100));
}

int main(int argc, char *argv[]){
	registerChecker("cup", argc, argv);

	ouf.readSecret(output_secret);
	ouf.readGraderResult();


	inf.readLine();//input_secret
	int tests = inf.readInt();


	int Q = 0;
	for (int test=0; test<tests; test++) {
		int t = ouf.readInt();
		if (t < 0) {
			Q = -1;
			break;
		}
		if (Q < t) {
			Q = t;
		}
	}
	if (Q < 0)
		quitf(_wa, "wrong cup location");
	if (1000 < Q)	qp(0);
	if (104 < Q)	qp(20);
	if (70 < Q)	qp(30);
	if (39 < Q)	qp(61);
	if (32 < Q)	qp(132-Q);
	// Q <= 32
	quit(_ok);
	return 0;
}

