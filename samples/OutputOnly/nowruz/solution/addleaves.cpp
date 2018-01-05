#include <iostream>
#include <string>
#include <vector>
using namespace std;

vector <string> table;
int m, n, k;
int xplus[4] = {0, 1, 0, -1}, yplus[4] = {1, 0, -1, 0};

int cnt_neighbors(int x, int y) {
    int cnt = 0;
    for (int i = 0; i < 4; i++)
	if (table[x+xplus[i]][y+yplus[i]] == 'X') cnt++;
    return cnt;
}

bool addleaves(int x, int y) {
    bool found = false;
    for (int i = 0; i < m; i++)
	for (int j = 0; j < n; j++)
	{
	    int a = 1 + (x + i) % m, b = 1 + (y + j) % n;
	    if (table[a][b] == '.' && cnt_neighbors(a, b) == 1) {
		table[a][b] = 'X'; 
		found = true;
	    }
	}
    return found;
}

int main() {
    cin >> m >> n >> k;
    string s(n, '#');
    table.push_back(s);
    for (int i = 0; i < m; i++) {
        cin >> s;
        table.push_back('#' + s + '#');
    }
    table.push_back(string(n, '#'));
    
    bool found = false;
    for (int i = 2; i < m + 1 && ! found; i++)
	for (int j = 2; j < n + 1 && ! found; j++)
	    if (table[i][j] == '.') {
		table[i][j] = 'X';
		addleaves(i, j);
		found = true;
	    }

    for(; addleaves(1,1););
    
    for (int i = 1; i < m + 1; i++)
	for (int j = 1; j < n + 1; j++)
	    if (table[i][j] == '.' || table[i][j] == 'X') table[i][j] = '.' + 'X' - table[i][j];
    for (int i = 1; i < m + 1; i++)
	cout << table[i].substr(1, n) << endl;

    return 0;
}
