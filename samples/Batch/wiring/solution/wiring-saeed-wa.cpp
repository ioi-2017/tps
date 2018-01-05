#include "wiring.h"

#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

const int MAXN = 1000000;

const long long inf = 1LL<<60;

int nex[MAXN];
long long sum[MAXN], dp[MAXN], f[MAXN];

inline long long get_sum(const int lo, const int hi){
	return sum[lo] - sum[hi+1];
}

long long min_total_length(vector <int> red, vector <int> blue){
	int n = blue.size(), m = red.size();
	vector< pair<int,int> > q;
	int pb = 0, pr = 0;
	while (pb < n || pr < m){
		if ((pr == m) || (pb < n && blue[pb] < red[pr]))
			q.push_back(make_pair(blue[pb++], 0));
		else
			q.push_back(make_pair(red[pr++], 1));
	}
	int nm = n + m;
	dp[nm-1] = inf, nex[nm-1] = nm, sum[nm-1] = q[nm-1].first;
	sum[nm] = 0, f[nm] = 0;
	for (int i = nm - 2; i >= 0; i--){
		dp[i] = inf;
		sum[i] = sum[i+1] + q[i].first;
		nex[i] = q[i].second == q[i+1].second ? nex[i+1] : i+1;
		if (nex[i] == i+1){
			for (int j = nex[i+1]-1; j >= i+1; j--)
				f[j] = min(dp[j], q[j].first - q[i].first + f[j+1]);
		}
		if (nex[i] == nm)
			continue;
		dp[i] = dp[i+1] + q[nex[i]].first - q[i].first;
		int sz = nex[i] - i;
		if (nex[i]+sz-1 <= nex[nex[i]])
			dp[i] = min(dp[i], get_sum(nex[i], nex[i]+sz-1) - get_sum(i, nex[i]-1) + f[nex[i]+sz]);
	}
	return dp[0];
}
