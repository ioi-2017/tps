#include <iostream>
#include "testlib.h"
using namespace std;

int main(int argc, char* argv[]) {
	registerGen(argc, argv, 1);
	int n = atoi(argv[1]);
	cout << n << endl;
	return 0;
}
