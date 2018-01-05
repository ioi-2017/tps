#include <iostream>
#include <set>
#include <map>
#include <vector>
#include "prize.h"
using namespace std;

typedef pair<int, int> interval;
typedef vector<interval> intvect;
typedef map<int, pair<int, int> > query_result;
typedef std::map<int, query_result > qmap;

vector<int>vtmp;

int find_best(int n) {
    intvect s;
    qmap q;
    s.push_back(interval(0, n-1));
    for(;;) {
	interval i = s.back();
	s.pop_back();
	int m = (i.first + i.second) / 2;
	vtmp=ask(m);
	pair <int, int> ans = pair<int,int>(vtmp[0],vtmp[1]);
	int l = ans.first, r = ans.second, sum = l + r;
//	cout << m << "\t" << l << "\t" << r << endl;
	if (sum == 0) return m;
	bool insert_left = true, insert_right = true;
        pair<int,int> res(l, r);
	if (q.find(sum) != q.end()) {
        	query_result::iterator a = q[sum].upper_bound(m);
//		cout << "Size " << sum << " Length " << q[sum].size() << endl;
//		cout << "Right " << a->first << " " << a->second.second << endl;
		if (a != q[sum].end() && r == a->second.second) insert_right = false;
        	if (a != q[sum].begin()) {
	            	a--;
//                       cout << "Left " << a->first << " " << a->second.first << endl;
			if (l == a->second.first) {
				insert_left = false;
				while (s.back().first >= a->first) s.pop_back();
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

