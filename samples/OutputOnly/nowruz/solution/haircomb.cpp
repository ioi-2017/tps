#include <iostream>
#include <vector>
#include <string>
#define For(a, b) for (int a = 0; a < b; a++)
using namespace std;
int m, n, k;
vector <string> table;

int main(int argc, char ** argv) {
    cin >> m >> n >> k;
    string s;
    For(i, m) {
	cin >> s;
	table.push_back(s);
    }
    int i = 0, j; 
    for (; i < n && table[0][i] != '.'; i++);
    for (j = i; j < n && table[0][j] == '.'; table[0][j++] = 'X')
	if (j % 3 == 0)
	    for (int k = 1; k < m; k++) {
		if (table[k][j] == '.') table[k][j] = 'X'; else break;
		if (k > 1 && (j + k) % 2 == 0) {
		    if (j > 1 && table[k][j-1] == '.') table[k][j-1] = 'X';
		    if (j < n - 1 && table[k][j+1] == '.') table[k][j+1] = 'X';
		}
	    }

    For(i, m) 
	For (j, n)
	    if (table[i][j] == '.' || table[i][j] == 'X') table[i][j] = '.' + 'X' - table[i][j];
    For (i, m)
	cout << table[i] << endl;
}
