#include <iostream>
#include <vector>
#include "testlib.h"
using namespace std;
const int MAX = 505;
int p[MAX];
vector<pair<int, int> > edges;
vector<int> adj[MAX];
vector<int> tree;
int par[MAX], cnt;
void init(int n)
{
	cnt = n;
	for (int i = 0; i < n; i++)
		par[i] = i;
}
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
	cnt--;
	return true;
}
void add_edge(int u, int v)
{
	if (rnd.next(0, 1))
		edges.push_back(make_pair(p[u], p[v]));
	else
		edges.push_back(make_pair(p[v], p[u]));
}
int main(int argc, char *argv[])
{
	registerGen(argc, argv, 1);
	int q = atoi(argv[1]);
	int n = atoi(argv[2]);
	int k = atoi(argv[3]);
	for (int i = 0; i < n; i++)
		p[i] = i;
	shuffle(p, p + n);
	init(n);
	for (int i = 0; i < n; i += k)
	{
		int x = min(n, i + k);
		for (int u = i; u < x; u++)
			for (int v = u + 1; v < x; v++)
			{
				add_edge(u, v);
				merge(u, v);
			}
	}
	while (cnt != 1)
	{
		int u = rnd.next(0, n - 1);
		int v = rnd.next(0, n - 1);
		if (merge(u, v))
			add_edge(u, v);
	}
	shuffle(edges.begin(), edges.end());
	for (int i = 0; i < edges.size(); i++)
	{
		adj[edges[i].first].push_back(i);
		adj[edges[i].second].push_back(i);
	}
	init(n);
	for (int i = 0; i < edges.size(); i++)
		if (merge(edges[i].first, edges[i].second))
			tree.push_back(i);
    shuffle(tree.begin(), tree.end());
	cout << "wrslcnopzlckvxbnair_input_simurgh_lmncvpisadngpiqdfngslcnvd" << endl;
	cout << n << " " << edges.size() << " " << q << "\n";
	for (int i = 0; i < edges.size(); i++)
		cout << edges[i].first << " " << edges[i].second << "\n";
	for (int i = 0; i < tree.size(); i++)
	{
		cout << tree[i];
		if (i + 1 < tree.size())
			cout << " ";
		else
			cout << "\n";
	}
	return 0;
}
