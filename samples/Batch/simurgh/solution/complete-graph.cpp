/*
	IOI 2017
	Problem: Finding Spanning Tree
	Author: PrinceOfPersia
	Subtask: 4
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
bool mark[maxn];
int ind[maxn][maxn], n, m, deg[maxn];
vi __edges_vec;
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
inline int query_vector(vi e){
	reset();
	rep(i, e)
		toggle(i);
	return query();
}
vi ans;
inline void calc_deg(int v){
	vi subset;
	For(u,0,n)	if(v != u)
		subset.pb(ind[v][u]);
	deg[v] = query_vector(subset);
}
int leaf = -1, other = -1;
inline bool edge_state(int e){
	int v = edges[e].x, u = edges[e].y;
	int w = 0;
	while(w == v or w == u)	++ w;
	reset();
	For(i,0,n)	if(i != v && i != u && i != w)
		toggle(ind[v][i]);
	toggle(ind[v][u]);
	toggle(ind[v][w]);
	toggle(ind[u][w]);

	toggle(ind[v][u]);
	int x = query();
	toggle(ind[v][u]);
	toggle(ind[v][w]);
	int y = query();
	toggle(ind[v][w]);
	toggle(ind[u][w]);
	int z = query();
	if(x == max(y, max(x, z)))
		return false;
	return true;
}
bool in_nei[maxn];
inline int neighbours(int v, vi nei){
	memset(in_nei, 0, sizeof in_nei);
	reset();
	rep(u, nei)	in_nei[u] = true, toggle(ind[v][u]);
	int sum = 0;
	For(u,0,n)	if(leaf != u && !in_nei[u]){
		toggle(ind[leaf][u]);
		if(u == other)
			++ sum;
	}
	return query() - sum;
}
inline void remove(int v){
	if(!deg[v] or mark[v])	return ;
	assert(deg[v] == 1);
	int the_u = -1;
	if(leaf == -1){
		leaf = v;
		For(u,0,n)	if(v != u && edge_state(ind[v][u])){
			other = u;
			break ;
		}
		the_u = other;
	}
	else{
		vi ed;
		For(u,0,n)	if(v != u && !mark[u])	ed.pb(u);
		int l = 0, r = ed.size() - 1;
		while(r > l){
			int mid = (l + r)/2;
			vi subset(ed.begin()+l, ed.begin()+mid+1);
			if(neighbours(v, subset))
				r = mid;
			else
				l = mid + 1;
		}
		the_u = ed[l];
	}
	int e = ind[v][the_u];
	int u = edges[e].x + edges[e].y - v;
	ans.pb(e);
	-- deg[u];
	mark[v] = true;
	if(deg[u] == 1)
		remove(u);
}
vi find_roads(int n, vi v, vi u){
	::n = n;
	if(n == 2){
		vi ans;
		ans.push_back(0);
		return ans;
	}
	m = v.size();
	memset(ind, -1, sizeof ind);
	For(i,0,m){
		edges[i] = {v[i], u[i]};
		ind[v[i]][u[i]] = ind[u[i]][v[i]] = i;
	}
	if(n == 2){
		toggle(0);
		query();
	}
	For(i,0,n)	calc_deg(i);
	For(i,0,n)	if(deg[i] == 1)	remove(i);
	query_vector(ans);
	return __ans;
}
