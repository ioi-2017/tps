// .... .... .....!
// ...... ......!
// .... ....... ..... ..!
// ...... ... ... .... ... .... .....!
// ... .. ... .... ...?
// ....... .. .... .. ...., ....... ..!

#include <vector>
#include <set>
#include <string>
#include <queue>
#include <iostream>
using namespace std;

#define rep(i, n) for (int i = 0, _n = (int)(n); i < _n; i++)
#define fer(i, x, n) for (int i = (int)(x), _n = (int)(n); i < _n; i++)
#define rof(i, n, x) for (int i = (int)(n), _x = (int)(x); i-- > _x; )
#define sz(x) (int((x).size()))
#define pb push_back
#define all(X) (X).begin(),(X).end()
#define X first
#define Y second
//#define endl '\n'

template<class P, class Q> inline void smin(P &a, Q b) { if (b < a) a = b; }
template<class P, class Q> inline void smax(P &a, Q b) { if (a < b) a = b; }

typedef long long ll;
typedef pair<int, int> pii;

////////////////////////////////////////////////////////////////////////////////

struct solver {
	const int dx[4] = {0, -1, 0, 1};
	const int dy[4] = {-1, 0, 1, 0};

	static const int maxn = 2048 + 64;

	static const char BLOCK = '#';
	static const char OPEN = '.';
	static const char TREE = 'X';

	int n, m;

	string ogrid[maxn];

	string grid[maxn];

	string bgrid[maxn];
	int best_ans;

	set<pair<int, pii>> s;

	inline bool inside(pii p) { return 0 <= p.X && p.X < n && 0 <= p.Y && p.Y < m; }
	inline bool open(pii p) { return inside(p) && grid[p.X][p.Y] == OPEN; }
	inline pii adj(pii p, int d) { return pii(p.X + dx[d], p.Y + dy[d]); }

	int around(pii p, char ch) { // counts number of ch's around p
		int cnt = 0;
		rep(d, 4) 
			if(inside(adj(p, d)) && grid[p.X + dx[d]][p.Y + dy[d]] == ch)
				cnt++;
			else if(!inside(adj(p, d)) && ch == BLOCK)
				cnt++;
		return cnt;
	}

	int extend(pii p, bool act) { // act: determines whether to apply it or not
		if(grid[p.X][p.Y] != OPEN || around(p, TREE) != 1) return -1;

		int cnt = 0;
		rep(d, 4) if(open(adj(p, d))) {
			if(around(adj(p, d), TREE) == 0) {
				if(act) add(adj(p, d));
				cnt++;
			}
		}
		if(act) grid[p.X][p.Y] = TREE;

		return cnt;
	}

	void add(pii p) { // add node p and extension options around p
		grid[p.X][p.Y] = TREE;
		rep(d, 4) if(open(pii(p.X + dx[d], p.Y + dy[d]))) {
			int cnt = extend(pii(p.X + dx[d], p.Y + dy[d]), 0);
			if(cnt != -1) s.insert({cnt, pii(p.X + dx[d], p.Y + dy[d])});
		}
	}

	vector <int> mark [maxn];
	int vmark = 727;
	vector<pii> q;

	int cnt_size(int x, int y) {
		int size = 1;
		vmark++;
		mark[x][y] = vmark;

		q.clear();
		q.pb(pii(x, y));
		int head = 0;

		while(head < sz(q)) {
			pii p = q[head++];
			rep(dir, 4) if(open(adj(p, dir)) && mark[p.X + dx[dir]][p.Y + dy[dir]] != vmark)
				mark[p.X + dx[dir]][p.Y + dy[dir]] = vmark, q.pb(adj(p, dir)), size++;
		}

		return size;
	}

	void init(int seed) {
		rep(x, n) mark[x].resize(maxn, 0);
		rep(x, n) rep(y, m) mark[x][y] = false;
		pii start;
		int best_cnt = -1;
		rep(x, n) rep(y, m) if(!mark[x][y] && grid[x][y] == OPEN) {
			int cnt = cnt_size(x, y);
			if(cnt > best_cnt) {
				best_cnt = cnt;

				srand(seed);
				start = q[rand() % sz(q)];
			}
		}
		add(start);
	}

	int dfs(int x, int y, bool st = true) {
		if(!open(pii(x, y)) || (!st && around(pii(x, y), TREE) > 0) || mark[x][y] == vmark)
			return 0;
		mark[x][y] = vmark;
		int res = 1;
		rep(dir, 4)
			res += dfs(x + dx[dir], y + dy[dir], false);
		return res;
	}

	int solve(int seed) {
		init(seed);
		
		while(true) {
			while(!s.empty()) {
				auto t = *s.rbegin();
				s.erase(*s.rbegin());

				int cnt = extend(t.second, 0);

				if(cnt == t.first)
					extend(t.second, 1);
				else if(cnt != -1)
					s.insert({cnt, t.second});
			}

			bool changed = false;

			rep(x, n) if(!changed) rep(y, m) if(!changed && grid[x][y] == OPEN && around(pii(x, y), TREE) == 1) {
				add(pii(x, y));
				changed = true;
			}

			rep(x, n) if(!changed) rep(y, m) if(!changed && grid[x][y] == OPEN && around(pii(x, y), TREE) == 2) {
				int cnt = 0;
				rep(dir, 4) {
					pii q = adj(pii(x, y), dir);
					if(inside(q) && grid[q.X][q.Y] == OPEN && around(q, TREE) == 0)
						cnt++;
				}

				if(cnt < 2) continue;

				rep(dir, 4) {
					pii q = adj(pii(x, y), dir);
					if(inside(q) && grid[q.X][q.Y] == TREE && around(q, TREE) == 1) {
						grid[q.X][q.Y] = OPEN;
						add(pii(x, y));
						changed = true;
						break;
					}
				}
			}

			rep(x, n) if(!changed) rep(y, m) if(!changed && grid[x][y] == OPEN && around(pii(x, y), TREE) == 2) {
				vmark++;
				int size = dfs(x, y);
				
				int cnt = 0;
				rep(dir, 4) {
					pii q = adj(pii(x, y), dir);
					if(inside(q) && grid[q.X][q.Y] == TREE && around(q, TREE) == 1)
						cnt++;
				}

				if((cnt == 2 && size < 7) || (size < 4)) continue;

				rep(dir, 4) {
					pii q = adj(pii(x, y), dir);
					if(inside(q) && grid[q.X][q.Y] == TREE && around(q, TREE) == 1) {
						grid[q.X][q.Y] = OPEN;
						add(pii(x, y));
						changed = true;
						break;
					}
				}
			}

			if(!changed) break;
		}

		int ans = 0;
		rep(x, n) rep(y, m) if(grid[x][y] == TREE && around(pii(x, y), TREE) == 1)
			ans++;

		if(ans > best_ans) {
			best_ans = ans;
			rep(x, n) bgrid[x] = grid[x];
		}

		return ans;
	}

	void read(bool first) {
		if(first) {
			cin >> n >> m;
			int tmp; cin >> tmp;
			rep(x, n) cin >> ogrid[x];

			best_ans = 0;
		}

		rep(x, n) grid[x] = ogrid[x];
	}

	void write() {
		rep(x, n) rep(y, m) if(bgrid[x][y] == '.' || bgrid[x][y] == 'X') bgrid[x][y] ^= 'X' ^ '.';
		rep(x, n) cout << bgrid[x] << endl;
	}
};

int main() {
	ios_base::sync_with_stdio(false); cin.tie(0);

	solver f;

	rep(i, 1) {
		f.read(i == 0);
		int tmp = f.solve((i + 7) * 27);

//		cerr << " ** iteration #" << i << ": " << tmp << endl;
	}

	f.write();

	return 0;
}

