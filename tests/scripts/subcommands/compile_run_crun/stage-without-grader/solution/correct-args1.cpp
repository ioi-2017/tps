#include <iostream>
using namespace std;

int main(int argc, char** argv) {
	printf("#args=%d\n", argc-1);
	for (int i = 1; i < argc; i++)
		printf("arg[%d]='%s'\n", i, argv[i]);
	int a, b;
	cin >> a >> b;
	cout << a+b << endl;
	return 0;
}
