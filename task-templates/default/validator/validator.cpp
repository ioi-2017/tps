#include "testlib.h"
using namespace std;

// $SecretI
const string input_secret = "__TPARAM_INPUT_SECRET__";
const int MAXN = 1000;

int main() {
	registerValidation();
// $SecretI
	inf.readToken(input_secret);
// $SecretI
	inf.readEoln();
	/*int n =*/ inf.readInt(1, MAXN, "n");
	inf.readEoln();
	inf.readEof();
	return 0;
}
