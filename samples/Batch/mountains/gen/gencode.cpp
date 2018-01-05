#include <iostream>
#include "testlib.h"
using namespace std;
const int MAXN = 2000;
const int MAXA = 1000000000;
int h[MAXN];
void print(int n)
{
	cout << "3f130aac-d629-40d9-b3ad-b75ea9aa8052" << endl;
	cout << n << endl;
	for (int i = 0; i < n; i++)
	{
		cout << h[i];
		if (i + 1 < n)
			cout << " ";
		else
			cout << endl;
	}
}
int main(int argc, char *argv[])
{
	registerGen(argc, argv);
	string type(argv[1]);
	if (type == "random")
	{
		int n = atoi(argv[2]);
		for (int i = 0; i < n; i++)
			h[i] = rnd.next(0, MAXA);
		print(n);
	}
	if (type == "zigzag")
	{
		int n = atoi(argv[2]);
		h[0] = 0;
		h[1] = 1;
		for (int i = 2; i < n; i += 2)
		{
			h[i] = 0;
			h[i + 1] = h[i - 1] * 3 + 1;
		}
		print(n);
	}
	if (type == "semi-manual")
	{
		int n = atoi(argv[2]);
		h[0] = 0;
		h[1] = 1;
		h[2] = 1000000;
		h[3] = 1500001;
		for (int i = 4; i < n - 1; i++)
			h[i] = h[i - 1] - i;
		h[n - 1] = 1000000000;
		print(n);
	}
	if (type == "magic")
	{
		int n = atoi(argv[2]);
		h[0] = 1000000000;
		h[1] = 0;
		h[2] = 1;
		h[3] = 1000000;
		h[4] = 1500001;
		h[5] = 1000000000;
		for (int i = 6; i < n - 6; i++)
			h[i] = h[i - 1] - i;
		h[n - 6] = 1000000000;
		h[n - 5] = 1500001;
		h[n - 4] = 1000000;
		h[n - 3] = 1;
		h[n - 2] = 0;
		h[n - 1] = 1000000000;
		print(n);
	}
	if (type == "slow_up")
	{
		int n = atoi(argv[2]);
		h[0] = 0;
		for (int i = 1; i < n; i++)
		{
			h[i] = h[i - 1];
			if (rnd.next(0, 2) == 0)
				h[i]++;
		}
		print(n);
	}
	if (type == "envlope")
	{
		int n = atoi(argv[2]);
		h[0] = 0;
		int t = 10000;
		for (int i = 1; i < n; i++, t--)
			h[i] = h[i - 1] + t;
		print(n);
	}
	if (type == "wall-envlope")
	{
		int n = atoi(argv[2]);
		h[0] = h[n - 1] = 1000000000;
		h[1] = 0;
		int t = 10000;
		for (int i = 2; i < n - 1; i++, t--)
			h[i] = h[i - 1] + t;
		print(n);
	}
	if (type == "sqr")
	{
		int n = atoi(argv[2]);
		for (int i = 0; i < n; i++)
			h[i] = i * i;
		int t = rnd.next(n / 20) + 5;
		for (int i = t; i < n; i += 2 * t)
			for (int j = i + 1; j < n && j < i + t; j++)
				h[j] = max(0, h[j] - 2 * (h[j] - h[i]));
		print(n);
	}
	if (type == "bpc")
	{
		int n = atoi(argv[2]);
		for (int i = 0; i < n; i++)
			h[i] = (1 << __builtin_popcount(i));
		print(n);
	}
	if (type == "inc")
	{
		int n = atoi(argv[2]);
		h[n - 1] = MAXA;
		for (int i = n - 2; i >= 0; i--)
			h[i] = max(0, h[i + 1] - rnd.next(0, h[i + 1] / 10));
		print(n);
	}
	return 0;
}
