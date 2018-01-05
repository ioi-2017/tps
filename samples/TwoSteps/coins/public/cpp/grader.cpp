#include "coins.h"
#include <iostream>
#include <vector>
#include <string>

using namespace std;

static string run_test() {
	int c;
	cin >> c;
	vector<int> b(64);
	for (int i = 0; i < 8; i++) {
		string s;
		cin >> s;
		for (int j = 0; j < 8; j++) {
			b[i * 8 + j] = int(s[j] - '0');
		}
	}
	vector<int> flips = coin_flips(b, c);
	if ((int)flips.size() == 0) {
		return "0 turn overs";
	}
	for (int i = 0; i < (int)flips.size(); i++) {
		if (flips[i] < 0 || flips[i] > 63) {
			return "cell number out of range";
		}
		b[flips[i]] = 1 - b[flips[i]];
	}
	int coin = find_coin(b);
	if (coin != c) {
		return "wrong coin";
	}
	return "ok";
}

int main() {
	int tests;
	cin >> tests;
	for (int t = 1; t <= tests; t++) {
		string result = run_test();
		cout << "test #" << t << ": " << result << endl;
	}
	return 0;
}
