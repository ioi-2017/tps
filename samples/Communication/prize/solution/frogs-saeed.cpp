#include "prize.h"

#include <iostream>
#include<vector>

using namespace std;

vector<int>vtmp;

int go(int lo, int hi, pair<int,int> left, pair<int,int> right) {
	if (lo > hi)
		return -1;
	int mid = (lo + hi) / 2;
	vtmp=ask(mid);
	pair<int,int> c = pair<int,int>(vtmp[0],vtmp[1]);
	if (c == pair<int,int>(0, 0))
		return mid;
	if (lo == hi)
		return -1;
	int ret = -1;
	if (c.first > 0 && c != left)
		ret = go(lo, mid-1, left, c);
	if (ret == -1 && c.second > 0 && c != right)
		ret = go(mid+1, hi, c, right);
	return ret;
}

int find_best(int n) {
	return go(0, n-1, pair<int,int>(-1,-1), pair<int,int>(-1,-1));	
}
