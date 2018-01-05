#include "simurgh.h"
#include <vector>
#include <cstring>
using namespace std;
const int MAX = 51;
int adj[MAX][MAX];
int edges[MAX], t;
int n, m;
bool mark[MAX], useable[MAX * MAX];
void dfs(int v)
{
	mark[v] = true;
	for (int u = 0; u < n; u++)
		if (adj[v][u] >= 0 && !mark[u])
		{
			edges[t++] = adj[v][u];
			dfs(u);
		}
}
void go(int v)
{
	mark[v] = true;
	for (int u = 0; u < n; u++)
		if (adj[v][u] >= 0 && !mark[u] && useable[adj[v][u]])
			go(u);
}
bool is_connected()
{
	memset(mark, 0, sizeof(mark));
	memset(useable, 0, sizeof(useable));
	for (int i = 0; i < n - 1; i++)
		useable[edges[i]] = true;
	go(0);
	for (int i = 0; i < n; i++)
		if (!mark[i])
			return false;
	return true;
}
vector<int> ANS;
int count_commons(){
	vector<int> x;
	for(int i = 0; i < n-1; ++ i)
		x.push_back(edges[i]);
	int res = count_common_roads(x);
	if(res == n-1)
		ANS = x;
	return res;
}
vector<int> find_roads(int _n, vector<int> u, vector<int> v)
{
	n = _n;
	m = v.size();
	memset(adj, -1, sizeof(adj));
	for (int i = 0; i < m; i++)
		adj[u[i]][v[i]] = adj[v[i]][u[i]] = i;
	dfs(0);
	while (true)
	{
		if(!ANS.empty())	return ANS;
		int cur = count_commons();
		for (int i = 0; i < n - 1; i++)
			for (int j = 0; j < m; j++)
				if (edges[i] != j)
				{
					int tmp = edges[i];
					edges[i] = j;
					if (is_connected())
					{
						int val = count_commons();
						if (cur < val)
							cur = val;
						else
							edges[i] = tmp;
					}
					else
						edges[i] = tmp;
				}
	}
}
