#include <iostream>
#include <string>
#include <vector>
#define For(a, b) for (int a = 0; a < b; a++)
using namespace std;

vector <string> table;
int m, n, k;
int xplus[4] = {0, 1, 0, -1}, yplus[4] = {1, 0, -1, 0};

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


bool add_leaves() {
    bool found = false;
    For(i, m)
	   For(j, n)
	      if (table[i][j] == '.' && neighbors(i, j) == 1) {
              table[i][j] = 'X';
              found = true;
          }
    return found;
}

int main() {
    cin >> m >> n >> k;
    string s;
    For(i, m) {
        cin >> s;
        table.push_back(s);
    }
    int dir = 0, x = 1, y = 0, u = 1, d = m - 2, l = -2, r = n - 2;
    bool found = false, blocked = false;
    while (r >= l && d >= u && ! blocked) {
    	while (! blocked) {
	    if (table[x][y] == '#') {if (found) blocked = true;}
	    else {table[x][y] = 'X'; found = true; }
    	    if (x + xplus[dir] >= u && x + xplus[dir] <= d && y + yplus[dir] >= l && y + yplus[dir] <= r) {
    		x += xplus[dir];
    		y += yplus[dir];
    	    } else break;
    	}
    	if (xplus[dir] > 0) u += 3; else d += 3 * xplus[dir];
    	if (yplus[dir] > 0) l += 3; else r += 3 * yplus[dir];
    	dir = (dir + 1) % 4;
    }
    add_leaves();
    For(i, m)
	For (j, n)
	    if (table[i][j] == '.' || table[i][j] == 'X') table[i][j] = '.' + 'X' - table[i][j];
    For (i, m)
	cout << table[i] << endl;

    return 0;
}
