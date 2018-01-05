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
int main(int argc, char ** argv){
	iOS;
	registerGen(argc, argv, 1);
	cout << "8ad886d6-2d9e-4cab-aaed-47175facae96" << endl;
	int T = 1000;
	cout << T << ' ' << argv[1] << endl;
	string s = "std";
	if(2 < argc)
		s = (string)argv[2];
	while(T--){
		int x;
		if(s == "std")
			x = rnd.next(64);
		else if(s == "c2")
			x = rnd.next(2);
		else if(s == "c3")
			x = rnd.next(3);
		else
			quitf(_fail, "invalid gen arguement, s = '%s'", s.c_str());

		cout << x << '\n';
		int ty = rnd.next(6);
		if(!ty){
			For(i,0,8){
				For(j,0,8)
					cout << rnd.next(2);
				cout << '\n';
			}
		}
		else if(ty == 1){
			For(i,0,8){
				For(j,0,8)
					cout << 0;
				cout << '\n';
			}
		}
		else if(ty == 2){
			For(i,0,8){
				For(j,0,8)
					cout << 1;
				cout << '\n';
			}
		}
		else if(ty == 3){
			int e = rnd.next(2);
			For(i,0,8){
				For(j,0,8)
					cout << (e ^ ((i & 1) == (j & 1)));
				cout << '\n';
			}
		}
		else{
			int r = rnd.next(8), c = rnd.next(8);
			For(i,0,8){
				For(j,0,8)
					cout << (ty == 4? (i == r && j == c? 0: 1): (i == r && j == c? 1: 0));
				cout << '\n';
			}
		}
	}
	return 0;
}

