#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main() {
    int m, n, k;
    cin >> m >> n >> k;
    string s;
    for (int i = 0; i < m; i++) {
        cin >> s;
	for (int j = 0; j < n; j++)
	    if (s[j] == '.') s[j] = 'X';
	cout << s << endl;
    }
    return 0;
}
