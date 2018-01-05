#include "wiring.h"
#include <vector>
#include <algorithm>
#include <iostream>
#include <cstring>
#include <cassert>

using namespace std;

typedef pair<int,bool> pie;

const bool BLUE = true, RED = false;
const int max_n = 200 * 1000; // TO BE DETERMINED

vector<pie> points;
long long d[max_n + 1], ps[max_n + 1];
int head[max_n], cnt[max_n];

long long val(int l, int r) {
	int m = head[r], x = r+1 - m, y = m - l;
	long long res = (ps[r+1] - ps[m]) - (ps[m] - ps[l]);
	if (x > y) res -= (long long)(x-y) * points[m-1].first;
	if (x < y) res += (long long)(y-x) * points[m].first;
	return res;
}

long long min_total_length (vector <int> red, vector <int> blue) {
	int n = blue.size(), m = red.size();
	for (int i = 0; i < n; i++) points.push_back(pie(blue[i], BLUE));
	for (int i = 0; i < m; i++) points.push_back(pie(red[i], RED));
	sort (points.begin(), points.end());

	n = points.size();
	for (int i = 1; i <= n; i++) ps[i] = ps[i-1] + points[i-1].first;

	long long *d = &(::d[1]);
	memset(d, 50, sizeof(long long) * n);

	for (int i = 1; i < n; i++) {
		head[i] = head[i-1];
		if (points[i].second != points[i-1].second) {
			int prev = head[i];
			head[i] = i;
			d[i] = d[i-1] + val(i-1, i);
			cnt[i] = 1;
			for (int j = prev; j < i; j++)
				if (d[i] > d[j-1] + val(j, i))
					cnt[i] = i - j, d[i] = d[j-1] + val(j, i);
		}
		else if (head[i] > 0) {
			cnt[i] = cnt[i-1];
			int j = head[i] - cnt[i];
			if (cnt[i-1] == i - head[i])
				if (j > head[j] && d[j-1] + val(j, i) > d[j-2] + val(j-1, i))
					cnt[i]++, j--;
			d[i] = min(d[j], d[j-1]) + val(j, i);
		}
	}
	return d[n-1];
}
