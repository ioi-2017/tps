#include "testlib.h"
#include <iostream>
#include <algorithm>
#include <set>
#include <vector>
#include <string>
#include <map>
#include <cmath>
#include <cstdio>
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
const int maxn = 1000 + 10;
int par[maxn];
bool A[maxn][maxn];
inline int root(int v){return par[v] < 0 ? v : par[v] = root(par[v]);}
inline bool merge(int x, int y){
	x = root(x), y = root(y);
	if(x == y)	return false;
	if(par[y] < par[x])	swap(x, y);
	par[x] += par[y];
	par[y] = x;
	return true;
}
int v[maxn * maxn], u[maxn * maxn];
string secret = "wrslcnopzlckvxbnair_input_simurgh_lmncvpisadngpiqdfngslcnvd";
int main() {
	iOS;
    registerValidation();
	memset(par, -1, sizeof par);
	string sec = inf.readLine();
	ensuref(sec == secret, "wrong secret");
	int n = inf.readInt(2, 500, "n");
	inf.readSpace();
	int m = inf.readInt(n-1, (n * (n-1))/2, "m");
	inf.readSpace();
	int q = inf.readInt(8000, 30000, "q");
	ensuref(q == 8000 || q == 12000 || q == 30000, "q value is not valid");
	inf.readEoln();
	For(i,0,m){
		v[i] = inf.readInt(0, n-1, "v"); inf.readSpace();
		u[i] = inf.readInt(0, n-1, "u"); inf.readEoln();
		ensuref(v[i] != u[i], "v_i = u_i");
		ensuref(!A[v[i]][u[i]], "given graph contains multiedges");
		A[v[i]][u[i]] = A[u[i]][v[i]] = true;
	}
	For(i,1,n){
		int x = inf.readInt(0, m-1, "g");
		if(i+1 == n)
			inf.readEoln();
		else
			inf.readSpace();
		ensuref(merge(v[x], u[x]), "given subgraph is not a tree");
	}
	inf.readEof();
	return 0;
}
