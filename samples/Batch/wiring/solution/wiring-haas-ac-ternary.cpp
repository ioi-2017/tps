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

const int TOF = 100;

vector<pie> points;
long long d[max_n + 1], ps[max_n + 1];
int head[max_n];

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
	for (int i = 0; i < n - 1; i++)
	 	assert(points[i].first != points[i + 1].first);
	for (int i = 1; i <= n; i++) ps[i] = ps[i-1] + points[i-1].first;

	long long *d = &(::d[1]);
	memset(d, 50, sizeof(long long) * n);

	for (int i = 1; i < n; i++) {
		head[i] = head[i-1];
		if (points[i].second != points[i-1].second) {
			int prev = head[i];
			head[i] = i;
			d[i] = d[i-1] + val(i-1, i);
			for (int j = prev; j < i; j++)
				if (d[i] > d[j-1] + val(j, i))
					d[i] = d[j-1] + val(j, i);
		}
		else if (head[i] > 0) {
			int l = head[head[i] - 1], r = head[i];
			if (l == 0)
				d[i] = val(0, i);
			else if (r - l < TOF)
				for (int j = l; j < r; j++)
					d[i] = min(d[i], min(d[j], d[j-1]) + val(j, i));
			else {
				while (r - l > 1) {
					int m = (r + l) / 2;
					if (d[m-1] + val(m, i) > d[m-2] + val(m-1, i))
						r = m;
					else
						l = m;
				}
				d[i] = d[l - 1] + val(l, i);
			}
		}
	}
	return d[n-1];
}
