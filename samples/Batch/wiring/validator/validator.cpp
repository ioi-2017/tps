#include "testlib.h"
#include <iostream>

using namespace std;

const int MAXN = 100000;
const int MAXX = 1000000000;

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
		if(i)
			ensuref(points[i].x > points[i - 1].x, "Red points must be in increasing order, but there exists pair %d, %d in this order in the input, at position %d.", points[i - 1].x, points[i].x, i);
	}
	inf.readEoln();
	for(int i = 0; i < m; i++)
	{
		if(i)
			inf.readSpace();
		points[i + n].x = inf.readInt(0, MAXX, "blue_i");
		points[i + n].color = BLUE;
		if(i)
			ensuref(points[i + n].x > points[i + n - 1].x, "Blue points must be in increasing order, but there exists pair %d, %d in this order in the input, at position %d.", points[i + n - 1].x, points[i + n].x, i);
	}
	inf.readEoln();
	inf.readEof();
	sort(points, points + n + m);
	for(int i = 0; i + 1 < n + m; i++)
		ensuref(points[i].x != points[i + 1].x, "Points must be different.");
	return 0;
}
