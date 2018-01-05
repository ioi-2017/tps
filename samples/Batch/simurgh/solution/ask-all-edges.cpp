/*
   	IOI 2017
	Problem: Finding Spanning Tree
	Author: PrinceOfPersia
	Subtask: 3
*/
#include <iostream>
#include <algorithm>
#include <set>
#include <vector>
#include <string>
#include <map>
#include <cmath>
#include <cstdio>
#include <cstring>
#include "simurgh.h"
using namespace std;
#define Foreach(i, c) for(__typeof((c).begin()) i = (c).begin(); i != (c).end(); ++i)
#define For(i,a,b) for(int (i)=(a);(i) < (b); ++(i))
#define rof(i,a,b) for(int (i)=(a);(i) > (b); --(i))
#define rep(i, c) for(auto &(i) : (c))
#define x first
#define y second
#define pb push_back
#define PB pop_back()
#define iOS ios_base::sync_with_stdio(false)
#define sqr(a) (((a) * (a)))
#define all(a) a.begin() , a.end()
#define error(x) cerr << #x << " = " << (x) <<endl
#define Error(a,b) cerr<<"( "<<#a<<" , "<<#b<<" ) = ( "<<(a)<<" , "<<(b)<<" )\n";
#define errop(a) cerr<<#a<<" = ( "<<((a).x)<<" , "<<((a).y)<<" )\n";
#define coud(a,b) cout<<fixed << setprecision((b)) << (a)
#define L(x) ((x)<<1)
#define R(x) (((x)<<1)+1)
#define umap unordered_map
#define double long double
typedef long long ll;
typedef pair<int,int>pii;
typedef vector<int> vi;
template <class T>  inline void smax(T &x,T y){ x = max((x), (y));}
template <class T>  inline void smin(T &x,T y){ x = min((x), (y));}
template <class T>	inline void sminmax(T &mn, T &mx, T x){smin(mn, x), smax(mx, x);}
const int maxn = 512, maxm = maxn * maxn / 2;
bool mark[maxn];
int h[maxn], ind[maxn][maxn], par[maxn], n, m, state[maxm], last_num[maxm];
int __edges[maxn];
vi __edges_vec;
vi adj[maxn];
pii edges[maxm];
bool bit[maxm];
int _next_ = 1;
int _last_id[maxm];
inline void _renew(){
	vi __edges_new;
	rep(i, __edges_vec)	if(bit[i] && _last_id[i] != _next_)
		__edges_new.pb(i), _last_id[i] = _next_;
	++ _next_;
	__edges_vec = __edges_new;
}
vi __ans;
inline int query(){
	_renew();
	int res = count_common_roads(__edges_vec);
	if(res == n-1)
		__ans = __edges_vec;
	return res;
}
inline void toggle(int i){
	if(!bit[i]){
		bit[i] = true;
		__edges_vec.pb(i);
	}
	else
		bit[i] = false;
}
inline void reset(){
	while(!__edges_vec.empty()){
		int e = __edges_vec.back();
		__edges_vec.PB;
		bit[e] = false;
	}
}
vi back_edges[maxn];
inline void dfs(int v = 0, int p = -1){
	if(~p)	h[v] = h[p] + 1;
	mark[v] = true;
	par[v] = p;
	rep(u, adj[v])
		if(!mark[u])
			dfs(u, v);
	if(~p)
		toggle(ind[v][p]);
}
int tree_score;
inline void DFS(int v = 0){
	rep(u, adj[v]){
		if(v == par[u])
			DFS(u);
		else if(u != par[v] && h[u] < h[v]){
			int e = ind[v][u];
			int cur = v;
			while(cur != u){
				back_edges[cur].pb(e);
				cur = par[cur];
			}
		}
	}
	if(~par[v]){
		int e2p = ind[v][par[v]];
		int for_a_one = -1, mn = tree_score, mx = mn;
		last_num[e2p] = tree_score;
		toggle(e2p);
		rep(e, back_edges[v]){
			if(min(for_a_one, state[e]) == -1){
				toggle(e);
				last_num[e] = query();
				if(~state[e])
					for_a_one = last_num[e] + (!state[e]);
				sminmax(mn, mx, last_num[e]);
				toggle(e);
			}
		}
		toggle(e2p);
		smax(mx, for_a_one);
		state[e2p] = tree_score == mx;
		rep(e, back_edges[v])	if(state[e] == -1)
			state[e] = last_num[e] == mx;
	}
	
}
vi find_roads(int n, vi v, vi u){
	::n = n;
	m = v.size();
	memset(ind, -1, sizeof ind);
	memset(state, -1, sizeof state);
	For(i,0,m){
		edges[i] = {v[i], u[i]};
		ind[v[i]][u[i]] = ind[u[i]][v[i]] = i;
		adj[v[i]].pb(u[i]), adj[u[i]].pb(v[i]);
	}
	dfs();
	tree_score = query();
	DFS();
	reset();
	For(i,0,m)	if(state[i] == 1)
		toggle(i);
	query();
	return __ans;
}
