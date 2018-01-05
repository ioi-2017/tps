#include "testlib.h"
#include <vector>
using namespace std;

static string output_secret = "lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs";
vector<int> ANS, RES; 
int main(int argc, char * argv[])
{
	registerChecker("simurgh", argc, argv);

	ouf.readSecret(output_secret);
	ouf.readGraderResult();

	inf.readLine();

	int n = inf.readInt(), m = inf.readInt();
    inf.readInt();
	for(int j = 0; j < m; ++ j)
		for(int i = 0; i < 2; ++ i)
			inf.readInt();
	for(int i = 1; i < n; ++ i)
		ANS.push_back(inf.readInt());
    for(int i = 0; i < n - 1; ++ i)
		RES.push_back(ouf.readInt());
    ouf.readEoln();
    ouf.readEof();

	sort(ANS.begin(), ANS.end());
	sort(RES.begin(), RES.end());

    if(ANS != RES)
		quitf(_fail, "wrong tree");

	quitf(_ok, "correct");
}
