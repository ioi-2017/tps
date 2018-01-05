#include "wiring.h"

#include <cassert>
#include <cstdio>
// BEGIN SECRET
#include <string>
// END SECRET

using namespace std;

int main() {
	// BEGIN SECRET
	const string input_secret = "071e691ce5776974f655a51a364bf5ca";
	const string output_secret = "9eb1604f9d1771bc19d90f43da7e264a";

	char secret[1000];
	assert(1 == scanf("%s", secret));
	if (string(secret) != input_secret) {
		printf("%s\n", output_secret.c_str());
		printf("SV\n");
		return 0;
	}
	// END SECRET
	int n, m;
	assert(2 == scanf("%d %d", &n, &m));

	vector<int> r(n), b(m);
	for(int i = 0; i < n; i++)
		assert(1 == scanf("%d", &r[i]));
	for(int i = 0; i < m; i++)
		assert(1 == scanf("%d", &b[i]));

	long long res = min_total_length(r, b);
	// BEGIN SECRET
	printf("%s\n", output_secret.c_str());
	printf("OK\n");
	// END SECRET
	printf("%lld\n", res);

	return 0;
}
