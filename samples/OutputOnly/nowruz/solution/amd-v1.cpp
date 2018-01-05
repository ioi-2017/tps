//
// Created by Amir on 7/24/17.
//

#include <iostream>
using namespace std;

int main(){
    int n, m;
    cin >> n >> m;
    int T = !(m & 1);
    for(int i = 0; i < n; ++ i) {
        for (int j = 0; j < m; ++j)
            if (((!(i % 3) && (j & 1) == T) || j == m - 1 || (i % 3 == 2 && j != m-2 && j % 2 == !T) || (i % 3 == 2 && j == m-3) || (i == n-1 && i % 3 == 0)) && !(i % 3 == 2 && j == m-2))
                cout << 'X';
            else
                cout << '.';
        cout << '\n';
    }
    return 0;
}