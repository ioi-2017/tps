#include "__TPARAM_SHORT_NAME__.h"
#include <cassert>
#include <cstdio>

int main() {
	int n;
	assert(1 == scanf("%d", &n));
	fclose(stdin);

	int res = __TPARAM_GRADER_FUNCTION_NAME__(n);

	printf("%d\n", res);
	fclose(stdout);
	return 0;
}
