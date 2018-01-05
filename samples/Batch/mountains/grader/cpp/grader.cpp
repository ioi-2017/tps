#include "mountains.h"
#include <cstdio>
#include <vector>
#include <cassert>
// BEGIN SECRET
#include <string>
// END SECRET

using namespace std;
// BEGIN SECRET
static string input_secret = "3f130aac-d629-40d9-b3ad-b75ea9aa8052";
static string output_secret = "f3697e79-76f0-4a15-8dc8-212253e98c61";
// END SECRET

int main() {
	// BEGIN SECRET
	char secret[1000];
	assert(1 == scanf("%s", secret));
	if (string(secret) != input_secret) {
		printf("%s\n", output_secret.c_str());
		printf("SV\n");
		return 0;
	}
	// END SECRET
	int n;
	assert(1 == scanf("%d", &n));
	std::vector<int> y(n);
	for (int i = 0; i < n; i++) {
		assert(1 == scanf("%d", &y[i]));
	}
	int result = maximum_deevs(y);
	// BEGIN SECRET
	printf("%s\n", output_secret.c_str());
	printf("OK\n");
	// END SECRET
	printf("%d\n", result);
	return 0;
}
