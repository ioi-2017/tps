#include "testlib.h"
using namespace std;

static string output_secret = "f3697e79-76f0-4a15-8dc8-212253e98c61";

int main(int argc, char * argv[])
{
	registerChecker("mountains", argc, argv);

	readBothSecrets(output_secret);
	readBothGraderResults();

	compareRemainingLines(3);
}
