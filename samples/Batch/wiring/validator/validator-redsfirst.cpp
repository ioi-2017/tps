#include "testlib.h"
#include <iostream>

using namespace std;

const int MAXN = 100000;
const int MAXX = 1000000000;

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
	int lastX = -1;
	for (int i = 0; i < n; i++) 
	{
		if(i)
			inf.readSpace();
		int curX = inf.readInt(0, MAXX, "red_i");
		if(i)
			ensuref(lastX < curX, "All the points must be in increasing order, but points #%d, #%d have coordinates #%d, #%d.", i - 1, i, lastX, curX);
		lastX = curX;
	}
	inf.readEoln();
	for(int i = 0; i < m; i++)
	{
		if(i)
			inf.readSpace();
		int curX = inf.readInt(0, MAXX, "blue_i");
		ensuref(lastX < curX, "All the points must be in increasing order, but points #%d, #%d have coordinates #%d, #%d.", n + i - 1, n + i, lastX, curX);
		lastX = curX;
	}
	inf.readEoln();
	inf.readEof();
	return 0;
}
