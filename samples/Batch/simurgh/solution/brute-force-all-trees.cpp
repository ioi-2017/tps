#include "simurgh.h"
using namespace std;
const int MAX = 7;
int par[MAX];
int find(int v)
{
	return (par[v] == v ? v : par[v] = find(par[v]));
}
bool merge(int u, int v)
{
	u = find(u);
	v = find(v);
	if (u == v)
		return false;
	par[u] = v;
	return true;
}
vector<int> find_roads(int n, vector<int> u, vector<int> v) {
	int m = v.size();
	for (int mask = 0; mask < (1 << m); mask++)
		if (__builtin_popcount(mask) == n - 1)
		{
			for (int i = 0; i < n; i++)
				par[i] = i;
			bool valid = true;
			vector<int> edges;
			for (int i = 0; i < m; i++)
				if ((1 << i) & mask)
				{
					edges.push_back(i);
					valid &= merge(u[i], v[i]);
				}
			if (valid && count_common_roads(edges) == n-1)
				return edges;
		}
}
