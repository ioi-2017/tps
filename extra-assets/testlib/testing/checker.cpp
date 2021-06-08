#include "../testlib-cms.h"
using namespace std;

static string output_secret = "the_output_secret_key";

int main(int argc, char * argv[])
{
	registerChecker("mountains", argc, argv);

	readBothSecrets(output_secret);
	readBothGraderResults();

	compareRemainingLines(3);
}
