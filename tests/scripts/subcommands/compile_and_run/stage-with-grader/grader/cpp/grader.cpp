#include "add1.h"
#include <cassert>
#include <cstdio>

int main() {
	int a, b;
	assert(2 == scanf("%d%d", &a, &b));
	fclose(stdin);

	int res = solve(a, b);

	// BEGIN SECRET
	printf("OK\n");
	// END SECRET
	printf("%d\n", res);
	fclose(stdout);
	return 0;
}
