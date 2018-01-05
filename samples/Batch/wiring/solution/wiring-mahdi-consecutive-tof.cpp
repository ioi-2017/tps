	//     . .. ... .... ..... be name khoda ..... .... ... .. .     \\

#include <bits/stdc++.h>
#include "wiring.h"
using namespace std;

inline int in() { int x; scanf("%d", &x); return x; }
const int N = 2000002;

const int BLUE = 1;
const int RED = 2;

struct Point
{
	int x, color;
	bool operator <(const Point &p) const { return x < p.x; }
};

Point p[N], tmp[N];
int blockRightCnt[N];

long long min_total_length(vector<int> red, vector<int> blue)
{
	int nb = blue.size();
	int nr = red.size();
	for(int i = 0; i < nb; i++)
	{
		tmp[i].x = blue[i];
		tmp[i].color = BLUE;
	}
	for(int i = 0; i < nr; i++)
	{
		tmp[nb + i].x = red[i];
		tmp[nb + i].color = RED;
	}
	merge(tmp, tmp + nb, tmp + nb, tmp + nb + nr, p + 1);

	long long ans = 0;
	int n = nb + nr;
	int st = 1, lastSz = 0;
	for(int i = 1; i <= n; i++)
	{
		if(i == n || p[i].color != p[i + 1].color)
		{
			int sz = i - st + 1;
			long long sum = 0;
			if(i == n)
				blockRightCnt[i] = 0;
			else if(st == 1)
				blockRightCnt[i] = sz;
			else
				blockRightCnt[i] = (sz + (lastSz <= sz/2))/2;
//			sum = 1LL * blockRightCnt[i] * (blockRightCnt[i] - 1)/2;
			for(int j = 0; j < blockRightCnt[i]; j++)
				sum += p[i].x - p[i - j].x;
			for(int j = i - blockRightCnt[i]; j >= st; j--)
				sum += p[j].x - p[st].x;
//			sum += 1LL * (sz - blockRightCnt[i]) * (sz - blockRightCnt[i] - 1)/2;
			if(st != 1)
				sum += 1LL * (p[st].x - p[st - 1].x) * max(blockRightCnt[st - 1], sz - blockRightCnt[i]);
			ans += sum;
			st = i + 1;
			lastSz = blockRightCnt[i];
		}
	}
	return ans;
}
