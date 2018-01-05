// .... .... .....!
// ...... ......!
// .... ....... ..... ..!
// ...... ... ... .... ... .... .....!
// ... .. ... .... ...?

#include "wiring.h"
#include<bits/stdc++.h>
using namespace std;

#define rep(i, n) for (int i = 0, _n = (int)(n); i < _n; i++)
#define fer(i, x, n) for (int i = (int)(x), _n = (int)(n); i < _n; i++)
#define rof(i, n, x) for (int i = (int)(n), _x = (int)(x); i-- > _x; )
#define sz(x) (int((x).size()))
#define pb push_back
#define all(X) (X).begin(),(X).end()
#define X first
#define Y second
#define endl '\n'

template<class P, class Q> inline void smin(P &a, Q b) { if (b < a) a = b; }
template<class P, class Q> inline void smax(P &a, Q b) { if (a < b) a = b; }

typedef long long ll;
typedef pair<int, int> pii;

////////////////////////////////////////////////////////////////////////////////

const ll infll = 1LL << 62;
const int maxn = 500000 + 100;

int n;
pii p[maxn];
int st[maxn], ed[maxn];
ll ps[maxn];
ll dp[maxn][2];

long long min_total_length (vector <int> red, vector <int> blue) {
	int nb = blue.size(), nr = red.size();
	rep(i, nb) p[i] = pii(blue[i], 0);
	rep(i, nr) p[i+nb] = pii(red[i], 1);
	
	n = nb + nr;
	sort(p, p+n);

	rep(i, n) st[i] = (i == 0 || p[i].Y != p[i-1].Y ? i : st[i-1]);
	rof(i, n, 0) ed[i] = (i == n-1 || p[i].Y != p[i+1].Y ? i+1 : ed[i+1]);

	ps[0] = 0;
	rep(i, n) ps[i+1] = ps[i] + p[i].X;

	rep(i, n+1) dp[i][0] = dp[i][1] = infll;
	dp[0][0] = 0;
	fer(i, 1, n+1) {
		int s = st[i-1];
		int e = ed[i-1];

		if(s == i-1) smin(dp[i][0], dp[i-1][1]);
		if(s != 0) {
			smin(dp[i][0], dp[i-1][0] + p[i-1].X - p[s-1].X);
			int len = i - s;
			if(s - len >= 0) smin(dp[i][0], dp[s - len][0] + (ps[i] - ps[s]) - (ps[s] - ps[s - len]));
		}
		if(e != n) smin(dp[i][1], dp[i-1][0] + p[e].X - p[i-1].X);
		smin(dp[i][0], dp[i][1]);
	}

	return dp[n][0];
}
/*
int nr, nb;
int x[maxn], y[maxn];

int main() {
	cin >> nr >> nb;
	rep(i, nr) cin >> x[i];
	rep(i, nb) cin >> y[i];
	cout << min_total_distance(nr, x, nb, y) << endl;
}
*/
