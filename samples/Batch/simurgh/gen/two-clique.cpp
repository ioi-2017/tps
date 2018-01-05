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
	int x = atoi(argv[3]);
	for (int i = 0; i < n; i++)
		p[i] = i;
	shuffle(p, p + n);
	init(n);
	for (int k = 0; k < 2; k++)
		for (int i = k * n / 2; i < (k + 1) * n / 2; i++)
			for (int j = i + 1; j < (k + 1) * n / 2; j++)
				add_edge(i, j);
	shuffle(edges.begin(), edges.end());
	for (int i = 0; i < n / 2; i++)
		add_edge(i, i + n / 2);
	if (x == 0)
		swap(edges[0], edges.back());
	reverse(edges.begin(), edges.end());
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
