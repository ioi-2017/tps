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
int a[maxn][maxn][maxn][maxn], n, ac[maxn][maxn][maxn][maxn];
int cnt = 0;
inline string tos(int x){
	stringstream ss;
	ss << x;
	string s;
	ss >> s;
	return s;
}
inline string norm(int x){
	++ x;
	return tos(x);
}
inline int sz(){
	return (int)tos(n * n).size();
}
typedef pair<pii, pii> cell;
vector<cell> cs;
int main(int argc, char **argv){
	registerGen(argc, argv, 1);
	iOS;
	n = atoi(argv[1]);
	memset(a, -1, sizeof a);
	int k = n * n * n * n;
	if(2 < argc)
			k = atoi(argv[2]);
		For(x,0,n)
		For(y,0,n)
		For(i,0,n)
			For(j,0,n)
				cs.pb({{x, y}, {i, j}});
	vi row;
	For(i,0,n*n)
		row.pb(i);
	shuffle(all(cs));
	cs.resize(n * n * n * n - k);
	vi cur;
	vi rows[2], cols[2];
	For(i,0,n)
		For(j,0,2)
		rows[j].pb(i), cols[j].pb(i);
	For(j,0,2){
		shuffle(all(rows[j]));
		shuffle(all(cols[j]));
	}
	For(x,0,n){
		cur = row;
		int nx = 0;
		For(i,0,n){
			nx = 0;
			For(y,0,n)
				For(j,0,n)
				ac[x][y][i][j] = cur[nx ++];
			rotate(cur.begin(), cur.begin() + n, cur.end()); 
		}
		rotate(row.begin(), row.begin() + 1, row.end());
	}
	For(x,0,n)
		For(y,0,n)
		For(i,0,n)
		For(j,0,n)
		a[rows[0][x]][cols[0][y]][rows[1][i]][cols[1][j]] = ac[x][y][i][j];

	rep(c, cs){
		int x = c.x.x, y = c.x.y, i = c.y.x, j = c.y.y;
		a[x][y][i][j] = -1;
	}

	cout << n << endl;
	For(x,0,n)
		For(i,0,n)
			For(y,0,n)
				For(j,0,n)
					cout << norm(a[x][y][i][j]) << " \n"[y + 1 == n && j + 1 == n];
	return 0;

}
