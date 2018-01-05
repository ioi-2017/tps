#include <iostream>
#include <string>
#include <vector>
#define For(a, b) for (int a = 0; a < b; a++)
#define max_tries (10)
using namespace std;
#define ipair pair <int, int>
vector <string> table, first, best;
int m, n, k, best_num;
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
            cerr << "Tie found" << endl;
            return true;
        }
    }

}

// dir = 0 : forward, 1: backward, 2: random
bool add_leaves(int x, int y, int dir) {
    bool found = false;
    if (dir == 2) {
        for (int i = 0; i < m * n; i++)
            allcells[i] = allcells[rand() % (i+1)];
        for (int i = 0; i < m * n; i++) found |= check_leaf(allcells[i].first, allcells[i].second);
    } else
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


void try_add_leaves(int x, int y, bool random) {
    For(i, m)
    	For(j, n) {
            int a = (i + x) % m, b = (j + y) % n;
    	    if (table[a][b] == '.') {
                table[a][b] = 'X';
                if (random) for (;add_leaves(0, 0, 2););
                else for (int l = 0; add_leaves(a, b, l % 2); l++);
        		int cur_num = count_leaves();
                if (cur_num > best_num) {
            	    best = table;
            	    best_num = cur_num;
                    cerr << best_num << endl;
            	}
                table = first;
                return;
            }
        }
}

int main() {
    cin >> m >> n >> k;
    string s;
    For(i, m) {
        cin >> s;
        table.push_back(s);
        For(j, n)
            allcells.push_back(ipair(i, j));
    }
    first = table;
    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            try_add_leaves(i, j, false);
    for (int tries = 0; tries < max_tries; tries++) {
        try_add_leaves(rand() % m, rand() % n, false);
        try_add_leaves(rand() % m, rand() % n, true);
    }
    For(i, m)
    	For (j, n)
    	    if (best[i][j] == '.' || best[i][j] == 'X') best[i][j] = '.' + 'X' - best[i][j];
    For (i, m)
	   cout << best[i] << endl;

    return 0;
}
