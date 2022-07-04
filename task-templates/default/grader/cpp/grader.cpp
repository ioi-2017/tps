#include "__TPARAM_SHORT_NAME__.h"
#include <cassert>
#include <cstdio>
// $Secret
// BEGIN SECRET
// $Secret
#include <string>
// $Secret
// END SECRET

int main() {
// $Secret
	// BEGIN SECRET
// $SecretI
	const std::string input_secret = "__TPARAM_INPUT_SECRET__";
// $SecretO
	const std::string output_secret = "__TPARAM_OUTPUT_SECRET__";
// $SecretI
	char secret[1000];
// $SecretI
	assert(1 == scanf("%999s", secret));
// $SecretI
	if (std::string(secret) != input_secret) {
// $SecretIO
		printf("%s\n", output_secret.c_str());
// $SecretI
		printf("PV\n");
// $SecretI
		printf("Possible tampering with the input\n");
// $SecretI
		fclose(stdout);
// $SecretI
		return 0;
// $SecretI
	}
// $Secret
	// END SECRET
	int n;
	assert(1 == scanf("%d", &n));
	fclose(stdin);

	int res = __TPARAM_GRADER_FUNCTION_NAME__(n);

	// BEGIN SECRET
// $SecretO
	printf("%s\n", output_secret.c_str());
	printf("OK\n");
	// END SECRET
	printf("%d\n", res);
	fclose(stdout);
	return 0;
}
