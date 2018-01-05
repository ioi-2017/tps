#include "mountains.h"
#include <cstdio>
#include <vector>
#include <cassert>

using namespace std;

int main() {
	int n;
	assert(1 == scanf("%d", &n));
	std::vector<int> y(n);
	for (int i = 0; i < n; i++) {
		assert(1 == scanf("%d", &y[i]));
	}
	int result = maximum_deevs(y);
	printf("%d\n", result);
	return 0;
}
