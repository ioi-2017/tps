#include "testlib.h"
using namespace std;
const int MAXN = 2000;
const int MAXY = 1000000000;
int main()
{
	registerValidation();
	string secret = inf.readLine();
	ensuref(secret == (string)"3f130aac-d629-40d9-b3ad-b75ea9aa8052", "Secret not found!");
	int n = inf.readInt(1, MAXN, "n");
	inf.readEoln();
	for (int i = 0; i < n; i++)
	{
		inf.readInt(0, MAXY, "y_i");
		if (i + 1 < n)
			inf.readSpace();
		else
			inf.readEoln();
	}
	inf.readEof();
	return 0;
}
