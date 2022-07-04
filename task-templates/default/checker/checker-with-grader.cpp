#include "testlib.h"
using namespace std;

// $SecretO
const string output_secret = "__TPARAM_OUTPUT_SECRET__";
// $SecretO

int main(int argc, char* argv[]) {
	registerChecker("__TPARAM_SHORT_NAME__", argc, argv);
// $SecretO
	readBothSecrets(output_secret);
	readBothGraderResults();
// $SecretO
	compareRemainingLines(3);
// $!SecretO
	compareRemainingLines(2);
}
