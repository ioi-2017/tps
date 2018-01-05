#include "simurgh.h"

#include <bits/stdc++.h>

using namespace std;

bool mark[1 << 27];
vector< pair<int,int> > adj[1 << 26];

vector<int> tree;

void dfs (int v) {
	mark[v] = true;
	for (int i = 0; i < (int)adj[v].size(); i++) if (!mark[adj[v][i].first]) {
		tree.push_back(adj[v][i].second);
		dfs(adj[v][i].first);
	}
}


vector<int> find_roads(int n, vector<int> u, vector<int> v) {
	for (int i = 0; i < (int)u.size(); i++) {
		adj[u[i]].push_back(make_pair(v[i], i));
		adj[v[i]].push_back(make_pair(u[i], i));
	}
	dfs(0);
	int t = 0;
	while (t < 30000) {
		count_common_roads(tree);
		t++;
	}
	while (true) {
	}
	return tree;
}
