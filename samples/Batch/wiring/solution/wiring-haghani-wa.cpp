#include <algorithm>
#include <iostream>
#include <cstring>
#include <vector>
#include "wiring.h"
using namespace std;
const int INF = 1000000005;
const int MAX = 100005;
const int TOF = 5;
vector<pair<int, int> > states;
int blue[MAX], red[MAX], n, m;
long long dp[MAX * TOF * 4];
void add_state(int i, int j)
{
	states.push_back(make_pair(i, j));
}
void create_states(int b, int r)
{
	if (blue[b] < red[r])
	{
		int lb = b + 1;
		while (lb < n && blue[lb] < red[r])
			lb++;
		int nxt_pos = INF;
		if (lb != n)
			nxt_pos = blue[lb];
		int pr = r;
		while (pr < m && red[pr] < nxt_pos)
		{
			for (int i = b; i < min(b + TOF, lb); i++)
				add_state(i, pr);
			for (int i = lb - 1; i >= max(lb - TOF, b); i--)
				add_state(i, pr);
			int mid = b + pr - r;
			for (int i = max(b, mid - TOF); i < min(mid + TOF, lb); i++)
				add_state(i, pr);
			pr++;
		}
		if (lb != n)
			create_states(lb, r);
	}
	else
	{
		int lr = r + 1;
		while (lr < m && red[lr] < blue[b])
			lr++;
		int nxt_pos = INF;
		if (lr != m)
			nxt_pos = red[lr];
		int pb = b;
		while (pb < n && blue[pb] < nxt_pos)
		{
			for (int i = r; i < min(r + TOF, lr); i++)
				add_state(pb, i);
			for (int i = lr - 1; i >= max(lr - TOF, r); i--)
				add_state(pb, i);
			int mid = r + pb - b;
			for (int i = max(r, mid - TOF); i < min(mid + TOF, lr); i++)
				add_state(pb, i);
			pb++;
		}
		if (lr != m)
			create_states(b, lr);
	}
}
int mp(pair<int, int> p)
{
	int id = lower_bound(states.begin(), states.end(), p) - states.begin();
	if (id < states.size() && states[id] == p)
		return id;
	return -1;
}
int abs(int x)
{
	return (x > 0 ? x : -x);
}
long long get(int id)
{
	if (id == -1)
		return 1e18;
	if (dp[id] != -1)
		return dp[id];
	dp[id] = 1e18;
	int i = states[id].first, j = states[id].second;
	if (!i && !j)
		return dp[id] = abs(blue[i] - red[j]);
	for (int ni = i; ni > i - 2; ni--)
		for (int nj = j; nj > j - 2; nj--)
			if (make_pair(ni, nj) != make_pair(i, j))
			{
				int nid = mp(make_pair(ni, nj));
				dp[id] = min(dp[id], get(nid) + abs(blue[i] - red[j]));
			}
	return dp[id];
}
long long min_total_length(vector <int> _red, vector <int> _blue)
{
	n = _blue.size();
	m = _red.size();
	for (int i = 0; i < n; i++)
		blue[i] = _blue[i];
	for (int i = 0; i < m; i++)
		red[i] = _red[i];
	create_states(0, 0);
	sort(states.begin(), states.end());
	states.resize(unique(states.begin(), states.end()) - states.begin());
	memset(dp, -1, sizeof(dp));
	return get(mp(make_pair(n - 1, m - 1)));
}
