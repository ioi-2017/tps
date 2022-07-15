#include <iostream>
#include <ctime>
using namespace std;

int main() {
	int a, b;
	cin >> a >> b;
	if (a > 1000) {
		int a0 = a;
		clock_t c_start = clock();
		while ((clock()-c_start) / CLOCKS_PER_SEC < 2.0) {
			// A busy loop
			for (int i = 0; i < 1000000; i++) {
				a += b;
				a %= 1000;
			}
		}
		if (a != a0)
			a = a0;
	}
	cout << a+b << endl;
	return 0;
}
