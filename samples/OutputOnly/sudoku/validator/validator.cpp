#include "testlib.h"
#include <bits/stdc++.h>
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
typedef complex<double> point;
template <class T>  inline void smax(T &x,T y){ x = max((x), (y));}
template <class T>  inline void smin(T &x,T y){ x = min((x), (y));}
const int maxn = 21;
int n;
int a[maxn][maxn][maxn][maxn];
inline void check_perm(vi v){
	sort(all(v));
	int x = v.size();
	v.resize(unique(all(v)) - v.begin());
	int y = v.size();
	ensuref(x == y, "invalid suduko");
}
inline void check_rows(){
	For(x,0,n)
		For(i,0,n){
			vi v;
			For(y,0,n)
				For(j,0,n)	if(~a[x][y][i][j])
					v.pb(a[x][y][i][j]);
			check_perm(v);
		}
}
inline void check_cols(){
	For(y,0,n)
		For(j,0,n){
			vi v;
			For(x,0,n)
				For(i,0,n)	if(~a[x][y][i][j])
					v.pb(a[x][y][i][j]);
			check_perm(v);
		}
}
inline void check_blocks(){
	For(x,0,n)
		For(y,0,n){
			vi v;
			For(i,0,n)
				For(j,0,n)	if(~a[x][y][i][j])
				v.pb(a[x][y][i][j]);
			check_perm(v);
		}
}
int main(int argc, char ** argv){
	iOS;
	memset(a, -1, sizeof a);
    registerValidation(argc, argv);
	n = inf.readInt(2, 20, "n");	inf.readEoln();
	For(x,0,n)
		For(i,0,n)
			For(y,0,n)
				For(j,0,n){
					int b = inf.readInt(0, n * n, "a");
					a[x][y][i][j] = -- b;
					if(y + 1 == n && j + 1 == n)	inf.readEoln();
					else	inf.readSpace();
				}
	check_rows();
	check_cols();
	check_blocks();
	inf.readEof();
	return 0;
}
