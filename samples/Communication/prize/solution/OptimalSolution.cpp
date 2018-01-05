#include <iostream>
#include <set>
#include <map>
#include <vector>
#include "prize.h"
using namespace std;

typedef pair<int, int> interval;
typedef vector<interval> intvect;
typedef map<int, pair<int, int> > query_result;
typedef map<int, query_result > qmap;
typedef map<int, vector<int> > fen_map; // Fenwick tree map

vector<int>vtmp;

void add(vector<int> &v, unsigned int pos, int val) {
    for (pos++; pos <= v.size(); pos += pos & -pos)
	v[pos] += val;
}

int total(vector<int> & v, unsigned int pos) {
    int s = 0;
    for (pos++; pos > 0; pos -= pos & -pos)
	s += v[pos];
    return s;
}

int total(vector<int> & v, unsigned int start, unsigned int end) {
    return total(v, end) - total(v, start - 1);
}

int total(fen_map & seen, int sum, unsigned int start, unsigned int end) {
    if (start > end) return 0;
    int t = 0;
    for (fen_map::iterator i = seen.begin(); i != seen.end(); i++) {
	if (i->first >= sum) break;
	t += total(i->second, start, end);
    }
    return t;
}

int find_best(int n) {
    intvect s;
    qmap q;
    fen_map seen; // Number of observed items of some generation
    s.push_back(interval(0, n-1));
    for(;;) {
	interval i = s.back();
	s.pop_back();
	int m = (i.first + i.second) / 2;
	bool check = true;
	// checking if interval i can contain solution, according to previous queries

	for (qmap::iterator g = q.begin(); g != q.end(); g++) {
	    query_result * qr = &g->second;
	    query_result::iterator a = qr->upper_bound(m);
	    int right_point = n - 1, right_num = 0, left_point = 0, left_num = n;
	    if (a != qr->end()) {
		right_point = a->first - 1;
		right_num = a->second.second;
		left_num = a->second.first + a->second.second;
	    }
	    if (a != qr->begin()) {
		a--;
		left_point = a->first + 1;
		left_num = a->second.second;
	    }
	    if (right_num +  total(seen, g->first, (unsigned) left_point, (unsigned) right_point) >= left_num) { 
		check = false;
		break;
	    }
	}	    
	if (! check) continue;
	vtmp=ask(m);
	pair <int, int> ans = pair<int,int>(vtmp[0],vtmp[1]);
	int l = ans.first, r = ans.second, sum = l + r;
	if (sum == 0) return m;
	if (seen.find(sum) == seen.end()) seen[sum] = vector<int>((unsigned) n+1, 0);
	add(seen[sum], (unsigned) m, 1);
	bool insert_left = true, insert_right = true;
        pair<int,int> res(l, r);
	if (q.find(sum) != q.end()) {
        	query_result::iterator a = q[sum].upper_bound(m);
		if (a != q[sum].end() && r == a->second.second) insert_right = false;
        	if (a != q[sum].begin()) {
	            	a--;
			if (l == a->second.first) {
				insert_left = false;
				while (!s.empty() && s.back().first >= a->first) s.pop_back();
			}
		}
	}
	q[sum][m] = res; 
	if (!l) s.clear();
	if (insert_left && i.first <= m - 1) s.push_back(interval(i.first, m-1));
	if (r && insert_right && i.second >= m+1) s.push_back(interval(m+1, i.second));
    }
    return 0;
}

