#include "testlib.h"
using namespace std;

static string output_secret = "9eb1604f9d1771bc19d90f43da7e264a";

int main(int argc, char * argv[])
{
	registerChecker("wiring", argc, argv);

	readBothSecrets(output_secret);
	readBothGraderResults();

	compareRemainingLines(3);
}
