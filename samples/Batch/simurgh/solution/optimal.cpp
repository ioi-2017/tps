/*
   	IOI 2017
	Problem: Finding Spanning Tree
	Author: PrinceOfPersia
	Subtask: 5
*/
#include <iostream>
#include <algorithm>
#include <set>
#include <vector>
#include <string>
#include <map>
#include <cmath>
#include <cstdio>
#include <cassert>
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
pii highest[maxn];
bool mark[maxn];
int h[maxn], ind[maxn][maxn], state[maxn], par[maxn], last_num[maxm], n, m, deg[maxn];
vi __edges_vec;
vi adj[maxn];
pii edges[maxm];
bool bit[maxm];
int _next_ = 1;
int _last_id[maxm];

vector<int> ANS;

inline void _renew(){
	vi __edges_new;
	rep(i, __edges_vec)	if(bit[i] && _last_id[i] != _next_)
		__edges_new.pb(i), _last_id[i] = _next_;
	++ _next_;
	__edges_vec = __edges_new;
}
inline int query(){
	_renew();
	int res =  count_common_roads(__edges_vec);
	if(res == n-1)
		ANS = __edges_vec;
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
inline void dfs(int v = 0, int p = -1){
	par[v] = p;
	mark[v] = true;
	highest[v] = {h[v], -1};
	rep(u, adj[v]){
		int e = ind[v][u];
		if(!mark[u]){
			h[u] = h[v] + 1;
			dfs(u, v);
			if(highest[v].x > highest[u].x)
				highest[v] = highest[u];
		}
		else if(highest[v].x > h[u] && u != p)
			highest[v] = {h[u], e};
	}
	if(~p)
		toggle(ind[v][p]);
}
inline void DFS(int v = 0){
	int p = par[v];
	rep(u, adj[v])	if(par[u] == v)	DFS(u);
	if(~p && state[v] == -1){
		if(highest[v].x > h[p]){
			state[v] = 1;
			return ;
		}
		int back_edge = highest[v].y;
		int x = edges[back_edge].x, y = edges[back_edge].y;
		if(h[x] > h[y])	swap(x, y);
		int back_edge_num = query();
		int mn = back_edge_num, mx = mn;
		int cur = y;
		int for_a_one = -1;
		toggle(back_edge);
		while(cur != x){
			if(state[cur] == -1 or for_a_one == -1){
				int cur_edge = ind[cur][par[cur]];
				toggle(cur_edge);
				last_num[cur_edge] = query();
				sminmax(mn, mx, last_num[cur_edge]);
				if(~state[cur])
					for_a_one = last_num[cur_edge] - (!state[cur]);
				toggle(cur_edge);
			}
			cur = par[cur];
		}
		toggle(back_edge);
		cur = y;
		while(cur != x){
			if(state[cur] == -1){
				int cur_edge = ind[cur][par[cur]];
				if(~for_a_one)
					state[cur] = last_num[cur_edge] == for_a_one;
				else if(mn == mx)
					state[cur] = 0;
				else
					state[cur] = last_num[cur_edge] == mn;
			}
			cur = par[cur];
		}
	}
}
vi tree, ans;
inline int root(int v){return par[v] < 0? v: par[v] = root(par[v]);}
inline bool merge(int ind){
	int x = edges[ind].x, y = edges[ind].y;
	x = root(x), y = root(y);
	if(x == y)	return false;
	toggle(ind);
	if(par[y] < par[x])	swap(x, y);
	par[x] += par[y];
	par[y] = x;
	return true;
}
inline int edge_state(int i){
	int x = edges[i].x, y = edges[i].y;
	if(h[x] > h[y])	swap(x, y);
	return state[y];
}
inline int query_for_forest(vi subset){
	reset();
	int sum = 0;
	memset(par, -1, sizeof par);
	rep(e, subset)
		merge(e);
	rep(e, tree)
		if(merge(e))
			sum += edge_state(e);
	return query() - sum;
}
inline void calc_deg(int v){
	vi subset;
	rep(u, adj[v])
		subset.pb(ind[v][u]);
	deg[v] = query_for_forest(subset);
}
inline void remove(int v){
	if(!deg[v] or mark[v])	return ;
	assert(deg[v] == 1);
	vi ed;
	rep(u, adj[v])	if(!mark[u])	ed.pb(ind[v][u]);
	int l = 0, r = ed.size() - 1;
	while(r > l){
		int mid = (l + r)/2;
		vi subset(ed.begin()+l, ed.begin()+mid+1);
		if(query_for_forest(subset))
			r = mid;
		else
			l = mid + 1;
	}
	int e = ed[l];
	int u = edges[e].x + edges[e].y - v;
	ans.pb(e);
	-- deg[u];
	mark[v] = true;
	if(deg[u] == 1)
		remove(u);
}
vi find_roads(int n, vi v, vi u){
	::n = n;
	::m = v.size();;
	memset(state, -1, sizeof state);
	memset(ind, -1, sizeof ind);
	For(i,0,m){
		edges[i] = {v[i], u[i]};
		ind[v[i]][u[i]] = ind[u[i]][v[i]] = i;
		adj[v[i]].pb(u[i]), adj[u[i]].pb(v[i]);
	}
	dfs();
	DFS();
	memset(mark, 0, sizeof mark);
	For(i,0,m)	if(bit[i])
		tree.pb(i);
	For(i,0,n)	calc_deg(i);
	For(i,0,n)	if(deg[i] == 1)	remove(i);
	query_for_forest(ans);
	return ANS;
}
