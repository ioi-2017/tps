// .... .... .....!
// ...... ......!
// .... ....... ..... ..!

#include <vector>
#include <string>
#include <iostream>
#include <set>
#include <queue>
#include "testlib.h"
using namespace std;

#define rep(i, n) for (int i = 0, _n = (int)(n); i < _n; i++)
#define fer(i, x, n) for (int i = (int)(x), _n = (int)(n); i < _n; i++)
#define rof(i, n, x) for (int i = (int)(n), _x = (int)(x); i-- > _x; )
#define sz(x) (int((x).size()))
#define pb push_back
#define all(X) (X).begin(),(X).end()
#define X first
#define Y second

template<class P, class Q> inline void smin(P &a, Q b) { if (b < a) a = b; }
template<class P, class Q> inline void smax(P &a, Q b) { if (a < b) a = b; }

typedef long long ll;
typedef pair<int, int> pii;

////////////////////////////////////////////////////////////////////////////////

const int maxn = 1024 + 10;

struct solver {
	const int dx[4] = {0, -1, 0, 1};
	const int dy[4] = {-1, 0, 1, 0};

	static const int maxn = 2048 + 64;

	static const char BLOCK = '#';
	static const char OPEN = '.';
	static const char TREE = 'X';

	int n, m;
	string grid[maxn];

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

	vector <int> mark[maxn];
	int vmark = 727;
	queue <pii> q;

	int cnt_size(int x, int y) {
		int size = 1;
		vmark++;
		mark[x][y] = vmark;
		q.push(pii(x, y));

		while(!q.empty()) {
			pii p = q.front();
			q.pop();
			rep(dir, 4) if(open(adj(p, dir)) && mark[p.X + dx[dir]][p.Y + dy[dir]] != vmark)
				mark[p.X + dx[dir]][p.Y + dy[dir]] = vmark, q.push(adj(p, dir)), size++;
		}

		return size;
	}

	void init() {
		rep(x, n) mark[x].resize(maxn, 0);
		pii start;
		int best_cnt = -1;
		rep(x, n) rep(y, m) if(!mark[x][y] && grid[x][y] == OPEN) {
			int cnt = cnt_size(x, y);
			if(cnt > best_cnt)
				best_cnt = cnt, start = pii(x, y);
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

	void solve() {
		init();

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
	}

	void read() {
		cin >> n >> m;
		int tmp; cin >> tmp;
		rep(x, n) cin >> grid[x];
	}

	void write() {
		rep(x, n) rep(y, m) if(grid[x][y] == '.' || grid[x][y] == 'X') grid[x][y] ^= 'X' ^ '.';
		rep(x, n) cout << grid[x] << endl;
	}
};

struct solver2 {
	#define For(a, b) for (int a = 0; a < b; a++)
	#define ipair pair <int, int>

	vector <string> table, first, best;
	int m, n, k, best_num = 0;
	int xplus[4] = {0, 1, 0, -1}, yplus[4] = {1, 0, -1, 0};
	vector < ipair > allcells;

	bool inside(int a, int b) {
	    return (a >= 0 && a < m && b >= 0 && b < n);
	}

	int neighbors(int x, int y) {
	    int count = 0;
	    For(i, 4) {
	        int a = x + xplus[i], b = y + yplus[i];
	        if (inside(a, b) && table[a][b] == 'X') count ++;
	    }
	    return count;
	}

	int count_leaves() {
	    int c = 0;
		For(i, m)
	    	For(j, n)
	            if (table[i][j] == 'X' && neighbors(i, j) == 1) c++;
		return c;
	}

	bool check_leaf(int x, int y) {
	    if (table[x][y] == '.' && neighbors(x, y) == 1) {
	        table[x][y] = 'X';
	        return true;
	    }
	    return false;
	}


	bool break_tie(int x, int y) {
	    if (table[x][y] != '.') return false;
	    bool leaf[4] = {0, 0, 0, 0};
	    int lnum = 0;
	    For(i, 4) {
	        int a = x + xplus[i], b = y + yplus[i];
	        if (table[a][b] == 'X') {
	            if (neighbors(a, b) != 1) return false;
	            leaf[i] = true;
	            lnum++;
	        }
	        else if (neighbors(a, b) != 0) return false;
	    }
	    if (lnum != 2) return false;
	    table[x][y] = 'X';
	    For(i, 4) {
	        if (leaf[i]) {
	            table[x + xplus[i]][y+yplus[i]] = '.';
	            return true;
	        }
	    }

	}

	// dir = 0 : forward, 1: backward
	bool add_leaves(int x, int y, int dir) {
	    bool found = false;
        For(i, m)
        	For(j, n) {
                int a = (dir) ? (m + x - i) % m : (i+x) % m;
                int b = (dir) ? (n + y - j) % n : (j+y) % n;
                found |= check_leaf(a, b);
        }
	    if (! found)
	        for (int i = 1; i < m - 1; i++)
	            for (int j = 1; j < n - 1; j++)
	                found |= break_tie(i, j);
	    return found;
	}


	void try_add_leaves(int x, int y) {
	    For(i, m)
	    	For(j, n) {
	            int a = (i + x) % m, b = (j + y) % n;
	    	    if (table[a][b] == '.') {
	                table[a][b] = 'X';
		            for (int l = 0; add_leaves(a, b, l % 2); l++);
	        		int cur_num = count_leaves();
	                if (cur_num > best_num) {
	            	    best = table;
	            	    best_num = cur_num;
		            }
	                table = first;
	                return;
	            }
	        }
	}

	int solve(int mm, int nn, string * grid) {
	    m = mm;
		n = nn;
		For(i, m)
			table.push_back(grid[i]);
	    first = table;
	    for (int i = 0; i < 3; i++)
	        for (int j = 0; j < 3; j++)
	            try_add_leaves(i, j);
		For(i, m)
	        For (j, n)
	            if (best[i][j] == '.' || best[i][j] == 'X') best[i][j] = '.' + 'X' - best[i][j];
	    return best_num;
	}

};

string grid[maxn];

int main(int argc, char** argv) {
	ios_base::sync_with_stdio(false); cin.tie(0);
	registerGen(argc, argv, 0);

	int n = atoi(argv[1]);
	int m = atoi(argv[2]);
	int p = atoi(argv[3]);

	rep(i, n) {
		grid[i] = string(m, '.');
		rep(j, m) if(rnd.next(100) < p) grid[i][j] = '#';
	}

	solver t;
	t.n = n, t.m = m;
	rep(x, n) t.grid[x] = grid[x];

	t.solve();

	int ans = 0;
	rep(x, n) rep(y, m) if(t.grid[x][y] == t.TREE && t.around(pii(x, y), t.TREE) == 1)
		ans++;

	solver2 t2;
	ans = max(ans, t2.solve(n, m, grid));

	ans -= 10;

	cout << n << ' ' << m << ' ' << ans << endl;
	rep(i, n) cout << grid[i] << endl;

	return 0;
}
