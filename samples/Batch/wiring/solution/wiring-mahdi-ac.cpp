	//     . .. ... .... ..... be name khoda ..... .... ... .. .     \\

#include<iostream>
#include<algorithm>
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
long long f[N], g[N], sum[N], dp[N];

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

	int n = nb + nr;
	int st = 1, lastSz = 0;
	for(int i = 1; i <= n; i++)
	{
		if(p[i].color != p[i - 1].color)
		{
			for(int j = i; p[j].color == p[i].color; j++)
				sum[i] += p[j].x;
			for(int j = i - 1; j >= st; j--)			
			{
				f[j] = -sum[j] + min(dp[j - 1], dp[j]) + 1LL * (i - j) * p[i - 1].x;
				if(j < i - 1)
					f[j] = min(f[j], f[j + 1]);
			}
			for(int j = st; j < i; j++)
			{
				g[j] = -sum[j] + min(dp[j - 1], dp[j]) + 1LL * (i - j) * p[i].x;
				if(j > st)
					g[j] = min(g[j], g[j - 1]);
			}
			lastSz = i - st;
			st = i;
		}
		else
			sum[i] = sum[i - 1] - p[i - 1].x;
		if(st == 1)
		{
			dp[i] = 1e18;
			continue;
		}
		int sz = i - st + 1;
		long long curSum = sum[st] - sum[i] + p[i].x;
		if(sz >= lastSz)
			dp[i] = f[st - lastSz] + curSum - 1LL * sz * p[st - 1].x;
		else
			dp[i] = min(g[st - sz - 1] + curSum - 1LL * sz * p[st].x,
						f[st - sz] + curSum - 1LL * sz * p[st - 1].x);
	}
	return dp[n];
}
