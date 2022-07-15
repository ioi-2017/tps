#include <iostream>
#include "testlib.h"
using namespace std;

int main(int argc, char* argv[]) {
	registerGen(argc, argv, 1);
	int a = atoi(argv[1]);
	int b = atoi(argv[2]);
	if (a > 10)
		exit(20);
	cout << a << " " << b << endl;
	return 0;
}
