#include <iostream>
#include "testlib.h"
using namespace std;

int main(int argc, char* argv[]) {
	registerGen(argc, argv, 1);
	int a = atoi(argv[1]);
	int b = atoi(argv[2]);
	cout << a << " " << b << endl;
	return 0;
}
