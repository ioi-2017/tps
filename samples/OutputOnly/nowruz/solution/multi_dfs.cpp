#include <iostream>
#include <vector>
#include <string>
#include <bitset>
#include <algorithm>
#define For(a, b) for (int a = 0; a < b; a++)
#define MAX (2048 + 64)
#define MAX_TRIES (1000)
const int rplus[4] = {0,0,1,-1}, cplus[4] = {-1, 1, 0, 0};
using namespace std;
int m, n, best_num;
double leaf_prob, best_prob;
vector <string> table, init, best;
int counter;

void rand_perm(int* p) {
    for (int i = 0; i < 4; i++) {
	p[i] = i;
	swap(p[i], p[rand() % (i + 1)]);
    }
}

bool check2(int r, int c) {
    return (r < 0 || r >= m || c < 0 || c >= n || table[r][c] != 'X');
}

bool check(int pr, int pc, int r, int c) {
    if (r < 0 || r >= m || c < 0 || c >= n || table[r][c] != '.') return false;
    For(i, 4) if ((r + rplus[i] != pr || c + cplus[i] != pc) && ! check2(r + rplus[i], c + cplus[i])) return false;
    return true;
}

void DFS(int r, int c) {
    table[r][c] = 'X';
    if (counter++ > 10 && ((double) rand() / RAND_MAX) < leaf_prob) return;
    int p[4];
    rand_perm(p);
    For(i, 4)
	if (check(r, c, r + rplus[p[i]], c + cplus[p[i]]))
	    DFS(r + rplus[p[i]], c + cplus[p[i]]);
}

bool inside(int a, int b) {
    return (a >= 0 && a < m && b >= 0 && b < n);
}

int neighbors(int x, int y) {
    int count = 0;
    For(i, 4) {
        int a = x + rplus[i], b = y + cplus[i];
        if (inside(a, b) && table[a][b] == 'X') count ++;
    }
    return count;
}

void add_leaves() {
    For(i, m)
           For(j, n)
              if (table[i][j] == '.' && neighbors(i, j) == 1) table[i][j] = 'X';
}

int count_leaves() {
    int num = 0;
    For(i, m)
           For(j, n)
              if (table[i][j] == 'X' && neighbors(i, j) == 1) num++;
    return num;
}

double fRand(double fMin, double fMax)
{
    double f = (double)rand() / RAND_MAX;
    return fMin + f * (fMax - fMin);
}

int main() {
//    leaf_prob = atof(argv[1]);
//    cerr << leaf_prob << endl;
    cin >> m >> n;
	int tmp; cin >> tmp;
    string s;
    int blocks = 0;
    For(i, m) {
    	cin >> s;
    	table.push_back(s);
    	blocks += count(s.begin(), s.end(), '#');
    }
    init = table;
    For(tries, MAX_TRIES) {
        table = init;
        leaf_prob = fRand(0, 0.25);
        int i = rand() % m, j = rand() % n;
        while (table[i][j] != '.') {
            j = (j + 1) % n;
            if (!j) i = (i + 1) % m;
        }
        DFS(i, j);
        add_leaves();
        int num = count_leaves();
        if (num > best_num) {
            best_num = num;
            best = table;
            best_prob = leaf_prob;
        }
    }

    For(i, m)
    	For (j, n)
    	    if (best[i][j] == '.' || best[i][j] == 'X') best[i][j] = '.' + 'X' - best[i][j];
    For (i, m)
	   cout << best[i] << endl;
//    cerr << best_num << " " << best_prob << endl;
}
