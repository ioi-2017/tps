#include "testlib.h"
#include <iostream>

using namespace std;

const int MAXN = 200;

static const string input_secret = "071e691ce5776974f655a51a364bf5ca";

int main() 
{
	registerValidation();
	string secret = inf.readLine();
	ensuref(secret == input_secret, "Secret not found!");
	int n = inf.readInt(1, MAXN, "n");
	inf.readSpace();
	int m = inf.readInt(1, MAXN, "m");
	inf.readEoln();
	skip_ok();
	return 0;
}
