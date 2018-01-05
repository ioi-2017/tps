#include "testlib.h"
#include <iostream>

using namespace std;

const int MAXN = 100000;
const int MAXX = 1000000000;
const int MAXBLOCKSIZE = 6;

enum Color {RED, BLUE};

struct Point
{
	int x;
	Color color;
	bool operator <(const Point &p) const { return x < p.x; }
};

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
	Point points[n + m];
	for (int i = 0; i < n; i++) 
	{
		if(i)
			inf.readSpace();
		points[i].x = inf.readInt(0, MAXX, "red_i");
		points[i].color = RED;
	}
	inf.readEoln();
	for(int i = 0; i < m; i++)
	{
		if(i)
			inf.readSpace();
		points[i + n].x = inf.readInt(0, MAXX, "blue_i");
		points[i + n].color = BLUE;
	}
	inf.readEoln();
	inf.readEof();
	sort(points, points + n + m);
	int lastRedIndex = -1, lastBlueIndex = -1;
	for(int i = 0; i < n + m; i++)
	{
		if(points[i].color == RED)
		{
			ensuref(i - lastBlueIndex <= MAXBLOCKSIZE, "Number of consecutive red points must not exceed %d", MAXBLOCKSIZE);
			lastRedIndex = i;
		}
		else
		{
			ensuref(i - lastRedIndex <= MAXBLOCKSIZE, "Number of consecutive blue points must not exceed %d", MAXBLOCKSIZE);
			lastBlueIndex = i;
		}
	}
	return 0;
}
