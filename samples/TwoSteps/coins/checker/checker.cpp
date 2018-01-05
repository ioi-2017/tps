#include "testlib.h"
using namespace std;

static string output_secret = "aa118b2a-086a-420f-811f-e3648ef86a25";

int main(int argc, char * argv[])
{
	registerChecker("coins", argc, argv);

	readBothSecrets(output_secret);
	readBothGraderResults();

	compareRemainingLines(3);
}
