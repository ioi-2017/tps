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

int main() {
	iOS;
	registerValidation();
	inf.readLine();
	int n = inf.readInt();
	const int maxn = 7;
	ensuref(n<=maxn, "n = %d > %d", n, maxn);
	inf.readSpace();
	inf.readInt();//m
	inf.readSpace();
	int q = inf.readInt();
	const int expq = 30000;
	ensuref(q==expq, "q=%d != %d", q, expq);
	skip_ok();
}
